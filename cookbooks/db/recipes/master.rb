#
# Cookbook:: db
# Recipe:: master
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

include_recipe "db::base"

passwords = data_bag_item("db", "passwords")

postgresql_user "tomh" do
  cluster node[:db][:cluster]
  superuser true
end

postgresql_user "matt" do
  cluster node[:db][:cluster]
  superuser true
end

postgresql_user "openstreetmap" do
  cluster node[:db][:cluster]
  password passwords["openstreetmap"]
end

postgresql_user "rails" do
  cluster node[:db][:cluster]
  password passwords["rails"]
end

postgresql_user "planetdump" do
  cluster node[:db][:cluster]
  password passwords["planetdump"]
end

postgresql_user "planetdiff" do
  cluster node[:db][:cluster]
  password passwords["planetdiff"]
  replication true
end

postgresql_user "backup" do
  cluster node[:db][:cluster]
  password passwords["backup"]
end

postgresql_user "gpximport" do
  cluster node[:db][:cluster]
  password passwords["gpximport"]
end

postgresql_user "munin" do
  cluster node[:db][:cluster]
  password passwords["munin"]
end

postgresql_user "replication" do
  cluster node[:db][:cluster]
  password passwords["replication"]
  replication true
end

postgresql_database "openstreetmap" do
  cluster node[:db][:cluster]
  owner "openstreetmap"
end

postgresql_extension "btree_gist" do
  cluster node[:db][:cluster]
  database "openstreetmap"
  only_if { node[:postgresql][:clusters][node[:db][:cluster]] && node[:postgresql][:clusters][node[:db][:cluster]][:version] >= 9.0 }
end

file "/etc/cron.daily/rails-db" do
  action :delete
end
