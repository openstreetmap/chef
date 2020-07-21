#
# Cookbook:: fail2ban
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

include_recipe "munin"

package "fail2ban"

template "/etc/fail2ban/jail.d/00-default.conf" do
  source "jail.default.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[fail2ban]"
end

template "/etc/fail2ban/paths-overrides.local" do
  source "paths-overrides.local.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[fail2ban]"
end

service "fail2ban" do
  action [:enable, :start]
end

munin_plugin "fail2ban"
