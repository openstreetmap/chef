#
# Cookbook:: planet
# Recipe:: notes
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
include_recipe "git"
include_recipe "planet::aws"

db_passwords = data_bag_item("db", "passwords")

package %w[
  pbzip2
  python3
  python3-psycopg2
  python3-lxml
]

directory "/opt/planet-notes-dump" do
  owner "root"
  group "root"
  mode "755"
end

git "/opt/planet-notes-dump" do
  action :sync
  repository "https://github.com/openstreetmap/planet-notes-dump.git"
  depth 1
  user "root"
  group "root"
end

template "/usr/local/bin/planet-notes-dump" do
  source "planet-notes-dump.erb"
  owner "root"
  group "root"
  mode "755"
  variables :password => db_passwords["planetdump"]
end

systemd_service "planet-notes-dump" do
  description "Create notes dump"
  exec_start "/usr/local/bin/planet-notes-dump"
  user "planet"
  sandbox :enable_network => true
  protect_home "tmpfs"
  bind_paths "/home/planet"
  read_write_paths "/store/planet/notes"
end

systemd_timer "planet-notes-dump" do
  description "Create notes dump"
  on_calendar "03:00"
end

service "planet-notes-dump.timer" do
  action [:enable, :start]
end

template "/usr/local/bin/planet-notes-cleanup" do
  source "planet-notes-cleanup.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "planet-notes-cleanup" do
  description "Delete old notes dumps"
  exec_start "/usr/local/bin/planet-notes-cleanup"
  user "planet"
  sandbox true
  read_write_paths "/store/planet/notes"
end

systemd_timer "planet-notes-cleanup" do
  description "Delete old notes dumps"
  on_calendar "08:10"
end

service "planet-notes-cleanup.timer" do
  action [:enable, :start]
end
