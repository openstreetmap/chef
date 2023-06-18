#
# Cookbook:: snmpd
# Recipe:: default
#
# Copyright:: 2013, OpenStreetMap Foundation
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

communities = data_bag_item("snmpd", "communities")

package "snmpd"

template "/etc/snmp/snmpd.conf" do
  source "snmpd.conf.erb"
  owner "root"
  group "root"
  mode "600"
  variables :communities => communities
  notifies :restart, "service[snmpd]"
end

service "snmpd" do
  action [:enable, :start]
  supports :status => true, :restart => true
end

firewall_rule "accept-snmp" do
  action :accept
  context :incoming
  protocol :udp
  source node[:snmpd][:clients] if node[:snmpd][:clients]
  dest_ports "snmp"
  source_ports "1024-65535"
end
