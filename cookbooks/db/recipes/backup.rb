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

cron_d "backup-db" do
  minute "00"
  hour "02"
  weekday "1"
  user "osmbackup"
  command "/usr/local/bin/backup-db"
  mailto "admins@openstreetmap.org"
end
