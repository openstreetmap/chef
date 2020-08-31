#
# Cookbook:: rsyncd
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

hosts_allow = {}
hosts_deny = {}

node[:rsyncd][:modules].each do |name, details|
  hosts_allow[name] = details[:hosts_allow] || []

  if details[:nodes_allow]
    hosts_allow[name] |= search(:node, details[:nodes_allow]).collect do |n|
      n.ipaddresses(:role => :external)
    end.flatten
  end

  hosts_deny[name] = details[:hosts_deny] || []

  next unless details[:nodes_deny]

  hosts_deny[name] |= search(:node, details[:nodes_deny]).collect do |n|
    n.ipaddresses(:role => :external)
  end.flatten
end

package "rsync"

systemd_service "rsync-override" do
  service "rsync"
  dropin "override"
  exec_start "/usr/bin/rsync --daemon --no-detach --bwlimit=16384"
  notifies :restart, "service[rsync]"
end

service "rsync" do
  action [:enable, :start]
  supports :status => true, :restart => true
end

template "/etc/default/rsync" do
  source "rsync.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[rsync]"
end

template "/etc/rsyncd.conf" do
  source "rsyncd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  variables :hosts_allow => hosts_allow, :hosts_deny => hosts_deny
end

firewall_rule "accept-rsync" do
  action :accept
  source "net"
  dest "fw"
  proto "tcp:syn"
  dest_ports "rsync"
  source_ports "1024:"
end
