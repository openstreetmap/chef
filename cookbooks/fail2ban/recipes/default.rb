#
# Cookbook Name:: fail2ban
# Recipe:: default
#
# Copyright 2013, OpenStreetMap Foundation
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

package "fail2ban"

template "/etc/fail2ban/jail.local" do
  source "jail.erb"
  owner "root"
  group "root"
  mode 0644
  variables :jails => []
end

service "fail2ban" do
  action [:enable, :start]
  supports :status => true, :reload => true, :restart => true
  subscribes :reload, "template[/etc/fail2ban/jail.local]"
end
