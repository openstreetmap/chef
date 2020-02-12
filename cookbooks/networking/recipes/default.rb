#
# Cookbook:: networking
# Recipe:: default
#
# Copyright:: 2010, OpenStreetMap Foundation.
# Copyright:: 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# = Requires
# * node[:networking][:nameservers]

require "ipaddr"
require "yaml"

package "netplan.io"

netplan = {
  "network" => {
    "version" => 2,
    "renderer" => "networkd",
    "ethernets" => {},
    "bonds" => {},
    "vlans" => {}
  }
}

node[:networking][:interfaces].each do |name, interface|
  if interface[:interface]
    if interface[:role] && (role = node[:networking][:roles][interface[:role]])
      if role[interface[:family]]
        node.normal[:networking][:interfaces][name][:prefix] = role[interface[:family]][:prefix]
        node.normal[:networking][:interfaces][name][:gateway] = role[interface[:family]][:gateway]
        node.normal[:networking][:interfaces][name][:routes] = role[interface[:family]][:routes]
      end

      node.normal[:networking][:interfaces][name][:metric] = role[:metric]
      node.normal[:networking][:interfaces][name][:zone] = role[:zone]
    end

    prefix = node[:networking][:interfaces][name][:prefix]

    node.normal[:networking][:interfaces][name][:netmask] = (~IPAddr.new(interface[:address]).mask(0)).mask(prefix)
    node.normal[:networking][:interfaces][name][:network] = IPAddr.new(interface[:address]).mask(prefix)

    interface = node[:networking][:interfaces][name]

    deviceplan = if interface[:interface] =~ /^(.*)\.(\d+)$/
                   netplan["network"]["vlans"][interface[:interface]] ||= {
                     "id" => Regexp.last_match(2).to_i,
                     "link" => Regexp.last_match(1),
                     "accept-ra" => false,
                     "addresses" => [],
                     "routes" => []
                   }
                 elsif interface[:interface] =~ /^bond\d+$/
                   netplan["network"]["bonds"][interface[:interface]] ||= {
                     "accept-ra" => false,
                     "addresses" => [],
                     "routes" => []
                   }
                 else
                   netplan["network"]["ethernets"][interface[:interface]] ||= {
                     "accept-ra" => false,
                     "addresses" => [],
                     "routes" => []
                   }
                 end

    deviceplan["addresses"].push("#{interface[:address]}/#{prefix}")

    if interface[:mtu]
      deviceplan["mtu"] = interface[:mtu]
    end

    if interface[:bond]
      deviceplan["interfaces"] = interface[:bond][:slaves].to_a

      deviceplan["parameters"] = {
        "mode" => interface[:bond][:mode] || "active-backup",
        "primary" => interface[:bond][:slaves].first,
        "mii-monitor-interval" => interface[:bond][:miimon] || 100,
        "down-delay" => interface[:bond][:downdelay] || 200,
        "up-delay" => interface[:bond][:updelay] || 200
      }

      deviceplan["parameters"]["transmit-hash-policy"] = interface[:bond][:xmithashpolicy] if interface[:bond][:xmithashpolicy]
      deviceplan["parameters"]["lacp-rate"] = interface[:bond][:lacprate] if interface[:bond][:lacprate]
    end

    if interface[:gateway]
      if interface[:family] == "inet"
        default_route = "0.0.0.0/0"
      elsif interface[:family] == "inet6"
        default_route = "::/0"
      end

      deviceplan["routes"].push(
        "to" => default_route,
        "via" => interface[:gateway],
        "metric" => interface[:metric],
        "on-link" => true
      )

      # This ordering relies on systemd-networkd adding routes
      # in reverse order and will need moving before the previous
      # route once that is fixed:
      #
      # https://github.com/systemd/systemd/issues/5430
      # https://github.com/systemd/systemd/pull/10938
      if interface[:family] == "inet6" &&
         !interface[:network].include?(interface[:gateway]) &&
         !IPAddr.new("fe80::/64").include?(interface[:gateway])
        deviceplan["routes"].push(
          "to" => interface[:gateway],
          "scope" => "link"
        )
      end
    end

    if interface[:routes]
      interface[:routes].each do |to, parameters|
        route = {
          "to" => to
        }

        route["type"] = parameters[:type] if parameters[:type]
        route["via"] = parameters[:via] if parameters[:via]
        route["metric"] = parameters[:metric] if parameters[:metric]

        deviceplan["routes"].push(route)
      end
    end
  else
    node.rm(:networking, :interfaces, name)
  end
end

netplan["network"]["bonds"].each_value do |bond|
  bond["interfaces"].each do |interface|
    netplan["network"]["ethernets"][interface] ||= { "accept-ra" => false }
  end
end

netplan["network"]["vlans"].each_value do |vlan|
  unless vlan["link"] =~ /^bond\d+$/
    netplan["network"]["ethernets"][vlan["link"]] ||= { "accept-ra" => false }
  end
end

file "/etc/netplan/01-netcfg.yaml" do
  action :delete
end

file "/etc/netplan/50-cloud-init.yaml" do
  action :delete
end

file "/etc/netplan/99-chef.yaml" do
  owner "root"
  group "root"
  mode 0o644
  content YAML.dump(netplan)
end

package "cloud-init" do
  action :purge
end

execute "hostname" do
  action :nothing
  command "/bin/hostname -F /etc/hostname"
end

template "/etc/hostname" do
  source "hostname.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :run, "execute[hostname]"
end

template "/etc/hosts" do
  source "hosts.erb"
  owner "root"
  group "root"
  mode 0o644
end

service "systemd-resolved" do
  action [:enable, :start]
end

directory "/etc/systemd/resolved.conf.d" do
  owner "root"
  group "root"
  mode 0o755
end

template "/etc/systemd/resolved.conf.d/99-chef.conf" do
  source "resolved.conf.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :restart, "service[systemd-resolved]", :immediately
end

if node[:filesystem][:by_mountpoint]["/etc/resolv.conf"]
  mount "/etc/resolv.conf" do
    action :umount
    device node[:filesystem][:by_mountpoint]["/etc/resolv.conf"][:devices].first
  end
end

link "/etc/resolv.conf" do
  to "../run/systemd/resolve/stub-resolv.conf"
end

if node[:networking][:tcp_fastopen_key]
  fastopen_keys = data_bag_item("networking", "fastopen")

  node.normal[:sysctl][:tcp_fastopen] = {
    :comment => "Set shared key for TCP fast open",
    :parameters => {
      "net.ipv4.tcp_fastopen_key" => fastopen_keys[node[:networking][:tcp_fastopen_key]]
    }
  }
end

node.interfaces(:role => :internal) do |interface|
  if interface[:gateway] && interface[:gateway] != interface[:address]
    search(:node, "networking_interfaces*address:#{interface[:gateway]}") do |gateway|
      next unless gateway[:openvpn]

      gateway[:openvpn][:tunnels].each_value do |tunnel|
        if tunnel[:peer][:address]
          route tunnel[:peer][:address] do
            netmask "255.255.255.255"
            gateway interface[:gateway]
            device interface[:interface]
          end
        end

        next unless tunnel[:peer][:networks]

        tunnel[:peer][:networks].each do |network|
          route network[:address] do
            netmask network[:netmask]
            gateway interface[:gateway]
            device interface[:interface]
          end
        end
      end
    end
  end
end

zones = {}

search(:node, "networking:interfaces").collect do |n|
  next if n[:fqdn] == node[:fqdn]

  n.interfaces.each do |interface|
    next unless interface[:role] == "external" && interface[:zone]

    zones[interface[:zone]] ||= {}
    zones[interface[:zone]][interface[:family]] ||= []
    zones[interface[:zone]][interface[:family]] << interface[:address]
  end
end

package "shorewall"

template "/etc/default/shorewall" do
  source "shorewall-default.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/shorewall.conf" do
  source "shorewall.conf.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/zones" do
  source "shorewall-zones.erb"
  owner "root"
  group "root"
  mode 0o644
  variables :type => "ipv4"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/interfaces" do
  source "shorewall-interfaces.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/hosts" do
  source "shorewall-hosts.erb"
  owner "root"
  group "root"
  mode 0o644
  variables :zones => zones
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/conntrack" do
  source "shorewall-conntrack.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :restart, "service[shorewall]"
  only_if { node[:networking][:firewall][:raw] }
end

template "/etc/shorewall/policy" do
  source "shorewall-policy.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/rules" do
  source "shorewall-rules.erb"
  owner "root"
  group "root"
  mode 0o644
  variables :family => "inet"
  notifies :restart, "service[shorewall]"
end

service "shorewall" do
  action [:enable, :start]
  supports :restart => true
  status_command "shorewall status"
end

template "/etc/logrotate.d/shorewall" do
  source "logrotate.shorewall.erb"
  owner "root"
  group "root"
  mode 0o644
  variables :name => "shorewall"
end

firewall_rule "limit-icmp-echo" do
  action :accept
  family :inet
  source "net"
  dest "fw"
  proto "icmp"
  dest_ports "echo-request"
  rate_limit "s:1/sec:5"
end

%w[ucl ams bm].each do |zone|
  firewall_rule "accept-openvpn-#{zone}" do
    action :accept
    source zone
    dest "fw"
    proto "udp"
    dest_ports "1194:1197"
    source_ports "1194:1197"
  end
end

if node[:roles].include?("gateway")
  template "/etc/shorewall/masq" do
    source "shorewall-masq.erb"
    owner "root"
    group "root"
    mode 0o644
    notifies :restart, "service[shorewall]"
  end
else
  file "/etc/shorewall/masq" do
    action :delete
    notifies :restart, "service[shorewall]"
  end
end

unless node.interfaces(:family => :inet6).empty?
  package "shorewall6"

  template "/etc/default/shorewall6" do
    source "shorewall-default.erb"
    owner "root"
    group "root"
    mode 0o644
    notifies :restart, "service[shorewall6]"
  end

  template "/etc/shorewall6/shorewall6.conf" do
    source "shorewall6.conf.erb"
    owner "root"
    group "root"
    mode 0o644
    notifies :restart, "service[shorewall6]"
  end

  template "/etc/shorewall6/zones" do
    source "shorewall-zones.erb"
    owner "root"
    group "root"
    mode 0o644
    variables :type => "ipv6"
    notifies :restart, "service[shorewall6]"
  end

  template "/etc/shorewall6/interfaces" do
    source "shorewall6-interfaces.erb"
    owner "root"
    group "root"
    mode 0o644
    notifies :restart, "service[shorewall6]"
  end

  template "/etc/shorewall6/hosts" do
    source "shorewall6-hosts.erb"
    owner "root"
    group "root"
    mode 0o644
    variables :zones => zones
    notifies :restart, "service[shorewall6]"
  end

  template "/etc/shorewall6/conntrack" do
    source "shorewall-conntrack.erb"
    owner "root"
    group "root"
    mode 0o644
    notifies :restart, "service[shorewall6]"
    only_if { node[:networking][:firewall][:raw] }
  end

  template "/etc/shorewall6/policy" do
    source "shorewall-policy.erb"
    owner "root"
    group "root"
    mode 0o644
    notifies :restart, "service[shorewall6]"
  end

  template "/etc/shorewall6/rules" do
    source "shorewall-rules.erb"
    owner "root"
    group "root"
    mode 0o644
    variables :family => "inet6"
    notifies :restart, "service[shorewall6]"
  end

  service "shorewall6" do
    action [:enable, :start]
    supports :restart => true
    status_command "shorewall6 status"
  end

  template "/etc/logrotate.d/shorewall6" do
    source "logrotate.shorewall.erb"
    owner "root"
    group "root"
    mode 0o644
    variables :name => "shorewall6"
  end

  firewall_rule "limit-icmp6-echo" do
    action :accept
    family :inet6
    source "net"
    dest "fw"
    proto "ipv6-icmp"
    dest_ports "echo-request"
    rate_limit "s:1/sec:5"
  end
end

firewall_rule "accept-http" do
  action :accept
  source "net"
  dest "fw"
  proto "tcp:syn"
  dest_ports "http"
  rate_limit node[:networking][:firewall][:http_rate_limit]
  connection_limit node[:networking][:firewall][:http_connection_limit]
end

firewall_rule "accept-https" do
  action :accept
  source "net"
  dest "fw"
  proto "tcp:syn"
  dest_ports "https"
  rate_limit node[:networking][:firewall][:http_rate_limit]
  connection_limit node[:networking][:firewall][:http_connection_limit]
end
