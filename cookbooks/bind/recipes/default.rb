#
# Cookbook:: bind
# Recipe:: default
#
# Copyright:: 2011, OpenStreetMap Foundation
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

include_recipe "networking"

clients = search(:node, "roles:#{node[:bind][:clients]}")

ipv4_clients = clients.collect do |client|
  client.ipaddresses(:family => :inet)
end.flatten

ipv6_clients = clients.collect do |client|
  client.ipaddresses(:family => :inet6)
end.flatten

package "bind9"

service_name = if node[:lsb][:release].to_f < 20.04
                 "bind9"
               else
                 "named"
               end

service service_name do
  action [:enable, :start]
end

template "/etc/bind/named.conf.local" do
  source "named.local.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[#{service_name}]"
end

template "/etc/bind/named.conf.options" do
  source "named.options.erb"
  owner "root"
  group "root"
  mode "644"
  variables :ipv4_clients => ipv4_clients, :ipv6_clients => ipv6_clients
  notifies :restart, "service[#{service_name}]"
end

template "/etc/bind/db.10" do
  source "db.10.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :reload, "service[#{service_name}]"
end

firewall_rule "accept-dns-udp" do
  action :accept
  source "net"
  dest "fw"
  proto "udp"
  dest_ports "domain"
  source_ports "-"
end

firewall_rule "accept-dns-tcp" do
  action :accept
  source "net"
  dest "fw"
  proto "tcp:syn"
  dest_ports "domain"
  source_ports "-"
end
