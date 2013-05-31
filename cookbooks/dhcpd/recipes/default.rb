#
# Cookbook Name:: dhcpd
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

if node[:lsb][:release].to_f < 12.04
  package_name = "dhcp3-server"
  config_file = "/etc/dhcp3/dhcpd.conf"
else
  package_name = "isc-dhcp-server"
  config_file = "/etc/dhcp/dhcpd.conf"
end

package package_name

domain = "#{node[:networking][:roles][:external][:zone]}.openstreetmap.org"

template config_file do
  source "dhcpd.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables :domain => domain
end

service package_name do
  action [ :enable, :start ]
  supports :status => true, :restart => true
  subscribes :restart, resources(:template => config_file)
end
