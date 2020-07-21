#
# Cookbook:: munin
# Recipe:: default
#
# Copyright:: 2010, OpenStreetMap Foundation
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

package "munin-node"

service "munin-node" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

servers = search(:node, "recipes:munin\\:\\:server")

servers.each do |server|
  server.interfaces(:role => :external) do |interface|
    firewall_rule "accept-munin-#{server}" do
      action :accept
      family interface[:family]
      source "#{interface[:zone]}:#{interface[:address]}"
      dest "fw"
      proto "tcp:syn"
      dest_ports "munin"
      source_ports "1024:"
    end
  end
end

template "/etc/munin/munin-node.conf" do
  source "munin-node.conf.erb"
  owner "root"
  group "root"
  mode "644"
  variables :servers => servers
  notifies :restart, "service[munin-node]"
end
