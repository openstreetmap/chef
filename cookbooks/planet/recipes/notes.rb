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

include_recipe "git"

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

cron_d "planet-notes-dump" do
  minute "0"
  hour "3"
  user "www-data"
  command "/usr/local/bin/planet-notes-dump"
  mailto "grant-smaug@firefishy.com"
end

cron_d "planet-notes-cleanup" do
  comment "Delete Planet Notes dump files older than 8 days"
  minute "10"
  hour "8"
  user "www-data"
  command "find /store/planet/notes/20??/ -maxdepth 1 -type f -iname 'planet-notes-??????.osn*' -printf '\%T@ \%p\n' | sort -k 1nr | sed 's/^[^ ]* //' | tail -n +17 | xargs -r rm -f"
  mailto "grant-smaug@firefishy.com"
end
