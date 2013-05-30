#
# Cookbook Name:: openssh
# Recipe:: default
#
# Copyright 2010, OpenStreetMap Foundation.
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "networking"

package "openssh-client"
package "openssh-server"

service "ssh" do
  action [ :enable, :start ]
  if node[:lsb][:release].to_f >= 10.04
    supports :status => true, :restart => true, :reload => true
  else 
    supports :restart => true, :reload => true
  end
end

hosts = search(:node, "networking:interfaces").sort_by do |node|
  node[:hostname]
end.collect do |node|
  names = [ node[:hostname] ]

  node.interfaces(:role => :external).each do |interface|
    names |= [ "#{node[:hostname]}.openstreetmap.org" ]
    names |= [ "#{node[:hostname]}.#{interface[:zone]}.openstreetmap.org" ]
  end

  unless node.interfaces(:role => :internal).empty?
    names |= [ "#{node[:hostname]}.#{node[:networking][:roles][:external][:zone]}.openstreetmap.org" ]
  end

  Hash[
    :names => names.sort,
    :addresses => node.ipaddresses.sort,
    :rsa => node[:keys][:ssh][:host_rsa_public],
    :dsa => node[:keys][:ssh][:host_dsa_public]
  ]
end

template "/etc/ssh/ssh_config" do
  source "ssh_config.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/etc/ssh/ssh_known_hosts" do
  source "ssh_known_hosts.erb"
  mode 0444
  owner "root"
  group "root"
  backup false
  variables(
    :hosts => hosts
  )
end

firewall_rule "accept-ssh" do
  action :accept
  source "net"
  dest "fw"
  proto "tcp:syn"
  dest_ports "ssh"
end
