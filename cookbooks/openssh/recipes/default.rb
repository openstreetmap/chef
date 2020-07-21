#
# Cookbook:: openssh
# Recipe:: default
#
# Copyright:: 2010, OpenStreetMap Foundation.
# Copyright:: 2008-2009, Opscode, Inc.
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

package "openssh-client"
package "openssh-server"

template "/etc/ssh/sshd_config.d/chef.conf" do
  source "sshd_config.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[ssh]"
  only_if { Dir.exist?("/etc/ssh/sshd_config.d") }
end

service "ssh" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

hosts = search(:node, "networking:interfaces").sort_by { |n| n[:hostname] }.collect do |node|
  name = node.name.split(".").first

  names = [name]

  unless node.interfaces(:role => :internal).empty?
    names.unshift("#{name}.#{node[:networking][:roles][:external][:zone]}.openstreetmap.org")
  end

  unless node.interfaces(:role => :external).empty?
    names.unshift("#{name}.openstreetmap.org")
  end

  keys = {
    "ssh-rsa" => node[:keys][:ssh][:host_rsa_public]
  }

  if node[:keys][:ssh][:host_ecdsa_public]
    ecdsa_type = node[:keys][:ssh][:host_ecdsa_type]

    keys[ecdsa_type] = node[:keys][:ssh][:host_ecdsa_public]
  end

  if node[:keys][:ssh][:host_ed25519_public]
    keys["ssh-ed25519"] = node[:keys][:ssh][:host_ed25519_public]
  end

  Hash[
    :names => names,
    :addresses => node.ipaddresses.sort,
    :keys => keys
  ]
end

template "/etc/ssh/ssh_known_hosts" do
  source "ssh_known_hosts.erb"
  mode "444"
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
  dest_ports node[:openssh][:port]
end
