#
# Cookbook Name:: planet
# Recipe:: dump
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

include_recipe "git"

db_passwords = data_bag_item("db", "passwords")

package "python-psycopg2"
package "python-lxml"

directory "/opt/planet-notes-dump" do
  owner "root"
  group "root"
  mode 0755
end

git "/opt/planet-notes-dump" do
  action :sync
  repository "git://github.com/openstreetmap/planet-notes-dump.git"
  user "root"
  group "root"
end

template "/usr/local/bin/planet-notes-dump" do
  source "planet-notes-dump.erb"
  owner "root"
  group "root"
  mode 0755
  variables :password => db_passwords["planetdump"]
end

template "/etc/cron.d/planet-notes-dump" do
  source "planet-notes-dump.cron.erb"
  owner "root"
  group "root"
  mode 0644
end
