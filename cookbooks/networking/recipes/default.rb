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
  action :delete
end

package "ifupdown" do
  action :purge
end

package "netplan.io" do
  action :purge
end

package "cloud-init" do
  action :purge
end

interfaces = node[:networking][:interfaces].collect do |name, interface|
  [interface[:interface], name]
end.to_h

node[:networking][:interfaces].each do |name, interface|
  if interface[:interface] =~ /^(.*)\.(\d+)$/
    vlan_interface = Regexp.last_match(1)
    vlan_id = Regexp.last_match(2)

    parent = interfaces[vlan_interface] || "vlans_#{vlan_interface}"

    node.default_unless[:networking][:interfaces][parent][:interface] = vlan_interface
    node.default_unless[:networking][:interfaces][parent][:vlans] = []

    node.default[:networking][:interfaces][parent][:vlans] << vlan_id
  end

  next unless interface[:role] && (role = node[:networking][:roles][interface[:role]])

  if interface[:inet] && role[:inet]
    node.default_unless[:networking][:interfaces][name][:inet][:prefix] = role[:inet][:prefix]
    node.default_unless[:networking][:interfaces][name][:inet][:gateway] = role[:inet][:gateway]
    node.default_unless[:networking][:interfaces][name][:inet][:routes] = role[:inet][:routes]
  end

  if interface[:inet6] && role[:inet6]
    node.default_unless[:networking][:interfaces][name][:inet6][:prefix] = role[:inet6][:prefix]
    node.default_unless[:networking][:interfaces][name][:inet6][:gateway] = role[:inet6][:gateway]
    node.default_unless[:networking][:interfaces][name][:inet6][:routes] = role[:inet6][:routes]
  end

  node.default_unless[:networking][:interfaces][name][:metric] = role[:metric]
  node.default_unless[:networking][:interfaces][name][:zone] = role[:zone]
end

node[:networking][:interfaces].each do |_, interface|
  if interface[:interface] =~ /^.*\.(\d+)$/
    template "/etc/systemd/network/10-#{interface[:interface]}.netdev" do
      source "vlan.netdev.erb"
      owner "root"
      group "root"
      mode "644"
      variables :interface => interface, :vlan => Regexp.last_match(1)
      notifies :run, "notify_group[networkctl-reload]"
    end
  elsif interface[:interface] =~ /^bond\d+$/
    template "/etc/systemd/network/10-#{interface[:interface]}.netdev" do
      source "bond.netdev.erb"
      owner "root"
      group "root"
      mode "644"
      variables :interface => interface
      notifies :run, "notify_group[networkctl-reload]"
    end

    interface[:bond][:slaves].each do |slave|
      template "/etc/systemd/network/10-#{slave}.network" do
        source "slave.network.erb"
        owner "root"
        group "root"
        mode "644"
        variables :master => interface, :slave => slave
        notifies :run, "notify_group[networkctl-reload]"
      end
    end
  end

  template "/etc/systemd/network/10-#{interface[:interface]}.network" do
    source "network.erb"
    owner "root"
    group "root"
    mode "644"
    variables :interface => interface
    notifies :run, "notify_group[networkctl-reload]"
  end
end

package "systemd-resolved" do
  action :install
  only_if { platform?("ubuntu") && node[:lsb][:release].to_f > 22.04 || platform?("debian") && node[:lsb][:release].to_f > 11.0 }
end

service "systemd-networkd" do
  action [:enable, :start]
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
    notifies :run, "notify_group[networkctl-reload]"
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
end

# Setup dokken network in systemd-networkd to avoid systemd-networkd-wait-online delay
template "/etc/systemd/network/dokken.network" do
  source "dokken.network.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :run, "execute[networkctl-reload]", :immediately
  only_if { kitchen? }
end

notify_group "networkctl-reload"

execute "networkctl-reload" do
  action :nothing
  command "networkctl reload"
  subscribes :run, "notify_group[networkctl-reload]"
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

firewall_rule "accept-http-osm" do
  action :accept
  context :incoming
  protocol :tcp
  source :osm
  dest_ports %w[http https]
end

firewall_rule "accept-http" do
  action :accept
  context :incoming
  protocol :tcp
  dest_ports %w[http https]
  rate_limit node[:networking][:firewall][:http_rate_limit]
  connection_limit node[:networking][:firewall][:http_connection_limit]
end
