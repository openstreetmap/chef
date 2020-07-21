#
# Cookbook:: dhcpd
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

package "isc-dhcp-server"

domain = "#{node[:networking][:roles][:external][:zone]}.openstreetmap.org"

template "/etc/dhcp/dhcpd.conf" do
  source "dhcpd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  variables :domain => domain
end

service "isc-dhcp-server" do
  action [:enable, :start]
  supports :status => true, :restart => true
  subscribes :restart, "template[/etc/dhcp/dhcpd.conf]"
end
