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

cookbook_file "/usr/local/share/monthly-reindex.sql" do
  owner "root"
  group "root"
  mode "644"
end

systemd_service "monthly-reindex" do
  description "Monthly database reindex"
  exec_start "/usr/bin/psql -f /usr/local/share/monthly-reindex.sql openstreetmap"
  user "postgres"
  sandbox true
  restrict_address_families "AF_UNIX"
end

systemd_timer "monthly-reindex" do
  description "Monthly database reindex"
  on_calendar "Sun *-*-1..7 02:00"
end

service "monthly-reindex.timer" do
  action [:enable, :start]
end

cookbook_file "/usr/local/share/yearly-reindex.sql" do
  owner "root"
  group "root"
  mode "644"
end

systemd_service "yearly-reindex" do
  description "Yearly database reindex"
  exec_start "/usr/bin/psql -f /usr/local/share/yearly-reindex.sql openstreetmap"
  user "postgres"
  sandbox true
  restrict_address_families "AF_UNIX"
end

systemd_timer "yearly-reindex" do
  description "Yearly database reindex"
  on_calendar "Fri *-1-8..14 02:00"
end

service "yearly-reindex.timer" do
  action [:enable, :start]
end
