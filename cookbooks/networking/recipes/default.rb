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

keys = data_bag_item("networking", "keys")

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
      if interface[:inet] && role[:inet]
        node.default[:networking][:interfaces][name][:inet][:prefix] = role[:inet][:prefix]
        node.default[:networking][:interfaces][name][:inet][:gateway] = role[:inet][:gateway]
        node.default[:networking][:interfaces][name][:inet][:routes] = role[:inet][:routes]
      end

      if interface[:inet6] && role[:inet6]
        node.default[:networking][:interfaces][name][:inet6][:prefix] = role[:inet6][:prefix]
        node.default[:networking][:interfaces][name][:inet6][:gateway] = role[:inet6][:gateway]
        node.default[:networking][:interfaces][name][:inet6][:routes] = role[:inet6][:routes]
      end

      node.default[:networking][:interfaces][name][:metric] = role[:metric]
      node.default[:networking][:interfaces][name][:zone] = role[:zone]
    end

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

    if interface[:inet]
      deviceplan["addresses"].push("#{interface[:inet][:address]}/#{interface[:inet][:prefix]}")
    end

    if interface[:inet6]
      deviceplan["addresses"].push("#{interface[:inet6][:address]}/#{interface[:inet6][:prefix]}")
    end

    if interface[:mtu]
      deviceplan["mtu"] = interface[:mtu]
    end

    if interface[:bond]
      deviceplan["interfaces"] = interface[:bond][:slaves].to_a

      deviceplan["parameters"] = {
        "mode" => interface[:bond][:mode] || "active-backup",
        "mii-monitor-interval" => interface[:bond][:miimon] || 100,
        "down-delay" => interface[:bond][:downdelay] || 200,
        "up-delay" => interface[:bond][:updelay] || 200
      }

      deviceplan["parameters"]["primary"] = interface[:bond][:slaves].first if deviceplan["parameters"]["mode"] == "active-backup"
      deviceplan["parameters"]["transmit-hash-policy"] = interface[:bond][:xmithashpolicy] if interface[:bond][:xmithashpolicy]
      deviceplan["parameters"]["lacp-rate"] = interface[:bond][:lacprate] if interface[:bond][:lacprate]
    end

    if interface[:inet]
      if interface[:inet][:gateway] && interface[:inet][:gateway] != interface[:inet][:address]
        deviceplan["routes"].push(
          "to" => "0.0.0.0/0",
          "via" => interface[:inet][:gateway],
          "metric" => interface[:metric],
          "on-link" => true
        )
      end

      if interface[:inet][:routes]
        interface[:inet][:routes].each do |to, parameters|
          next if parameters[:via] == interface[:inet][:address]

          route = {
            "to" => to
          }

          route["type"] = parameters[:type] if parameters[:type]
          route["via"] = parameters[:via] if parameters[:via]
          route["metric"] = parameters[:metric] if parameters[:metric]

          deviceplan["routes"].push(route)
        end
      end
    end

    if interface[:inet6]
      if interface[:inet6][:gateway] && interface[:inet6][:gateway] != interface[:inet6][:address]
        deviceplan["routes"].push(
          "to" => "::/0",
          "via" => interface[:inet6][:gateway],
          "metric" => interface[:metric],
          "on-link" => true
        )

        # This ordering relies on systemd-networkd adding routes
        # in reverse order and will need moving before the previous
        # route once that is fixed:
        #
        # https://github.com/systemd/systemd/issues/5430
        # https://github.com/systemd/systemd/pull/10938
        if !IPAddr.new(interface[:inet6][:address]).mask(interface[:inet6][:prefix]).include?(interface[:inet6][:gateway]) &&
           !IPAddr.new("fe80::/64").include?(interface[:inet6][:gateway])
          deviceplan["routes"].push(
            "to" => interface[:inet6][:gateway],
            "scope" => "link"
          )
        end
      end

      if interface[:inet6][:routes]
        interface[:inet6][:routes].each do |to, parameters|
          next if parameters[:via] == interface[:inet6][:address]

          route = {
            "to" => to
          }

          route["type"] = parameters[:type] if parameters[:type]
          route["via"] = parameters[:via] if parameters[:via]
          route["metric"] = parameters[:metric] if parameters[:metric]

          deviceplan["routes"].push(route)
        end
      end
    end
  else
    node.rm(:networking, :interfaces, name)
  end
end

netplan["network"]["bonds"].each_value do |bond|
  bond["interfaces"].each do |interface|
    netplan["network"]["ethernets"][interface] ||= { "accept-ra" => false, "optional" => true }
  end
end

netplan["network"]["vlans"].each_value do |vlan|
  unless vlan["link"] =~ /^bond\d+$/
    netplan["network"]["ethernets"][vlan["link"]] ||= { "accept-ra" => false }
  end
end

file "/etc/netplan/00-installer-config.yaml" do
  action :delete
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
  mode "644"
  content YAML.dump(netplan)
end

package "cloud-init" do
  action :purge
end

if node[:networking][:wireguard][:enabled]
  wireguard_id = persistent_token("networking", "wireguard")

  node.default[:networking][:wireguard][:address] = "fd43:e709:ea6d:1:#{wireguard_id[0, 4]}:#{wireguard_id[4, 4]}:#{wireguard_id[8, 4]}:#{wireguard_id[12, 4]}"

  package "wireguard-tools" do
    compile_time true
    options "--no-install-recommends"
  end

  directory "/var/lib/systemd/wireguard" do
    owner "root"
    group "systemd-network"
    mode "750"
    compile_time true
  end

  file "/var/lib/systemd/wireguard/private.key" do
    action :create_if_missing
    owner "root"
    group "systemd-network"
    mode "640"
    content %x(wg genkey)
    compile_time true
  end

  node.default[:networking][:wireguard][:public_key] = %x(wg pubkey < /var/lib/systemd/wireguard/private.key).chomp

  file "/var/lib/systemd/wireguard/preshared.key" do
    action :create_if_missing
    owner "root"
    group "systemd-network"
    mode "640"
    content keys["wireguard"]
  end

  if node[:roles].include?("gateway")
    search(:node, "roles:gateway") do |gateway|
      next if gateway.name == node.name
      next unless gateway[:networking][:wireguard] && gateway[:networking][:wireguard][:enabled]

      allowed_ips = gateway.ipaddresses(:role => :internal).map(&:subnet)

      node.default[:networking][:wireguard][:peers] << {
        :public_key => gateway[:networking][:wireguard][:public_key],
        :allowed_ips => allowed_ips,
        :endpoint => "#{gateway.name}:51820"
      }
    end

    search(:node, "roles:prometheus") do |server|
      allowed_ips = server.ipaddresses(:role => :internal).map(&:subnet)

      if server[:networking][:private_address]
        allowed_ips << "#{server[:networking][:private_address]}/32"
      end

      node.default[:networking][:wireguard][:peers] << {
        :public_key => server[:networking][:wireguard][:public_key],
        :allowed_ips => allowed_ips,
        :endpoint => "#{server.name}:51820"
      }
    end

    node.default[:networking][:wireguard][:peers] << {
      :public_key => "7Oj9ufNlgidyH/xDc+aHQKMjJPqTmD/ab13agMh6AxA=",
      :allowed_ips => "10.0.16.1/32",
      :endpoint => "gate.compton.nu:51820"
    }

    # Grant home
    node.default[:networking][:wireguard][:peers] << {
      :public_key => "RofATnvlWxP3mt87+QKRXFE5MVxtoCcTsJ+yftZYEE4=",
      :allowed_ips => "10.89.122.1/32",
      :endpoint => "gate.firefishy.com:51820"
    }

    # Grant roaming
    node.default[:networking][:wireguard][:peers] << {
      :public_key => "YbUkREE9TAmomqgL/4Fh2e5u2Hh7drN/2o5qg3ndRxg=",
      :allowed_ips => "10.89.123.1/32",
      :endpoint => "roaming.firefishy.com:51820"
    }
  elsif node[:roles].include?("shenron")
    search(:node, "roles:gateway") do |gateway|
      allowed_ips = gateway.ipaddresses(:role => :internal).map(&:subnet)

      node.default[:networking][:wireguard][:peers] << {
        :public_key => gateway[:networking][:wireguard][:public_key],
        :allowed_ips => allowed_ips,
        :endpoint => "#{gateway.name}:51820"
      }
    end
  end

  file "/etc/systemd/network/wireguard.netdev" do
    action :delete
  end

  template "/etc/systemd/network/10-wg0.netdev" do
    source "wireguard.netdev.erb"
    owner "root"
    group "systemd-network"
    mode "640"
    notifies :run, "execute[networkctl-delete-wg0]"
    notifies :run, "execute[networkctl-reload]"
  end

  file "/etc/systemd/network/wireguard.network" do
    action :delete
  end

  template "/etc/systemd/network/10-wg0.network" do
    source "wireguard.network.erb"
    owner "root"
    group "root"
    mode "644"
    notifies :run, "execute[networkctl-reload]"
  end

  execute "networkctl-delete-wg0" do
    action :nothing
    command "networkctl delete wg0"
    only_if { ::File.exist?("/sys/class/net/wg0") }
  end

  execute "networkctl-reload" do
    action :nothing
    command "networkctl reload"
    not_if { kitchen? }
  end
end

ohai "reload-hostname" do
  action :nothing
  plugin "hostname"
end

execute "hostnamectl-set-hostname" do
  command "hostnamectl set-hostname #{node[:networking][:hostname]}"
  notifies :reload, "ohai[reload-hostname]"
  not_if { kitchen? || node[:hostnamectl][:static_hostname] == node[:networking][:hostname] }
end

template "/etc/hosts" do
  source "hosts.erb"
  owner "root"
  group "root"
  mode "644"
  not_if { kitchen? }
end

service "systemd-resolved" do
  action [:enable, :start]
end

directory "/etc/systemd/resolved.conf.d" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/systemd/resolved.conf.d/99-chef.conf" do
  source "resolved.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[systemd-resolved]", :immediately
end

if node[:filesystem][:by_mountpoint][:"/etc/resolv.conf"]
  execute "umount-resolve-conf" do
    command "umount -c /etc/resolv.conf"
  end
end

link "/etc/resolv.conf" do
  to "../run/systemd/resolve/stub-resolv.conf"
end

hosts = { :inet => [], :inet6 => [] }

search(:node, "networking:interfaces").collect do |n|
  next if n[:fqdn] == node[:fqdn]

  n.interfaces.each do |interface|
    next unless interface[:role] == "external"

    hosts[:inet] << interface[:inet][:address] if interface[:inet]
    hosts[:inet6] << interface[:inet6][:address] if interface[:inet6]
  end
end

package "nftables"

interfaces = []

node.interfaces(:role => :external).each do |interface|
  interfaces << interface[:interface]
end

template "/etc/nftables.conf" do
  source "nftables.conf.erb"
  owner "root"
  group "root"
  mode "755"
  variables :interfaces => interfaces, :hosts => hosts
  notifies :reload, "service[nftables]"
end

directory "/var/lib/nftables" do
  owner "root"
  group "root"
  mode "755"
end

template "/usr/local/bin/nftables" do
  source "nftables.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "nftables-stop" do
  action :delete
  service "nftables"
  dropin "stop"
end

systemd_service "nftables-chef" do
  service "nftables"
  dropin "chef"
  exec_start "/usr/local/bin/nftables start"
  exec_reload "/usr/local/bin/nftables reload"
  exec_stop "/usr/local/bin/nftables stop"
end

if node[:networking][:firewall][:enabled]
  service "nftables" do
    action [:enable, :start]
  end
else
  service "nftables" do
    action [:disable, :stop]
  end
end

if node[:networking][:wireguard][:enabled]
  firewall_rule "accept-wireguard" do
    action :accept
    context :incoming
    protocol :udp
    source :osm unless node[:roles].include?("gateway")
    dest_ports "51820"
    source_ports "51820"
  end
end

firewall_rule "accept-http" do
  action :accept
  context :incoming
  protocol :tcp
  dest_ports %w[http https]
  rate_limit node[:networking][:firewall][:http_rate_limit]
  connection_limit node[:networking][:firewall][:http_connection_limit]
end
