#
# Cookbook:: db
# Recipe:: backup
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

template "/usr/local/bin/backup-db" do
  source "backup-db.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "backup-db" do
  description "Database backup"
  exec_start "/usr/local/bin/backup-db"
  user "osmbackup"
  sandbox :enable_network => true
  restrict_address_families "AF_UNIX"
  read_write_paths "/store/backup"
end

systemd_timer "backup-db" do
  description "Database backup"
  on_calendar "Mon 02:00 #{node[:timezone]}"
end

service "backup-db.timer" do
  action [:enable, :start]
end
