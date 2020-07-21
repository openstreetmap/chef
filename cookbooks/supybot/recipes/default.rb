#
# Cookbook:: supybot
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

include_recipe "accounts"

users = data_bag_item("supybot", "users")
passwords = data_bag_item("supybot", "passwords")

package "limnoria"
package "python3-git"

directory "/etc/supybot" do
  owner "supybot"
  group "supybot"
  mode "755"
end

template "/etc/supybot/supybot.conf" do
  source "supybot.conf.erb"
  owner "supybot"
  group "supybot"
  mode "644"
  variables :passwords => passwords
end

template "/etc/supybot/channels.conf" do
  source "channels.conf.erb"
  owner "supybot"
  group "supybot"
  mode "644"
end

template "/etc/supybot/git.conf" do
  source "git.conf.erb"
  owner "supybot"
  group "supybot"
  mode "644"
end

template "/etc/supybot/ignores.conf" do
  source "ignores.conf.erb"
  owner "supybot"
  group "supybot"
  mode "644"
end

template "/etc/supybot/userdata.conf" do
  source "userdata.conf.erb"
  owner "supybot"
  group "supybot"
  mode "644"
end

template "/etc/supybot/users.conf" do
  source "users.conf.erb"
  owner "supybot"
  group "supybot"
  mode "644"
  variables :passwords => users
end

directory "/var/lib/supybot" do
  owner "root"
  group "root"
  mode "755"
end

directory "/var/lib/supybot/data" do
  owner "supybot"
  group "supybot"
  mode "755"
end

directory "/var/lib/supybot/backup" do
  owner "supybot"
  group "supybot"
  mode "755"
end

directory "/var/lib/supybot/git" do
  owner "supybot"
  group "supybot"
  mode "755"
end

directory "/var/log/supybot" do
  owner "supybot"
  group "supybot"
  mode "755"
end

directory "/usr/local/lib/supybot" do
  owner "root"
  group "root"
  mode "755"
end

directory "/usr/local/lib/supybot/plugins" do
  owner "root"
  group "root"
  mode "755"
end

git "/usr/local/lib/supybot/plugins/Git" do
  action :sync
  repository "https://github.com/openstreetmap/supybot-git"
  revision "master"
  depth 1
  user "root"
  group "root"
end

systemd_service "supybot" do
  description "OpenStreetMap IRC Robot"
  after "network.target"
  user "supybot"
  exec_start "/usr/bin/supybot /etc/supybot/supybot.conf"
  private_tmp true
  private_devices true
  protect_system true
  protect_home true
  no_new_privileges true
  restart "on-failure"
end

service "supybot" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/supybot/supybot.conf]"
  subscribes :restart, "template[/etc/supybot/channels.conf]"
  subscribes :restart, "template[/etc/supybot/git.conf]"
  subscribes :restart, "template[/etc/supybot/ignores.conf]"
  subscribes :restart, "template[/etc/supybot/userdata.conf]"
  subscribes :restart, "template[/etc/supybot/users.conf]"
  subscribes :restart, "git[/usr/local/lib/supybot/plugins/Git]"
  subscribes :restart, "systemd_service[supybot]"
end
