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

postgresql_user "cgimap" do
  cluster node[:db][:cluster]
  password passwords["cgimap"]
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

CGIMAP_PERMISSIONS = {
  "changeset_comments" => [:select],
  "changeset_tags" => [:select],
  "changesets" => [:select, :update],
  "current_node_tags" => [:select, :insert, :delete],
  "current_nodes" => [:select, :insert, :update],
  "current_nodes_id_seq" => [:update],
  "current_relation_members" => [:select, :insert, :delete],
  "current_relation_tags" => [:select, :insert, :delete],
  "current_relations" => [:select, :insert, :update],
  "current_relations_id_seq" => [:update],
  "current_way_nodes" => [:select, :insert, :delete],
  "current_way_tags" => [:select, :insert, :delete],
  "current_ways" => [:select, :insert, :update],
  "current_ways_id_seq" => [:update],
  "issues" => [:select],
  "node_tags" => [:select, :insert],
  "nodes" => [:select, :insert],
  "oauth_access_grants" => [:select],
  "oauth_access_tokens" => [:select],
  "oauth_applications" => [:select],
  "relation_members" => [:select, :insert],
  "relation_tags" => [:select, :insert],
  "relations" => [:select, :insert],
  "reports" => [:select],
  "user_blocks" => [:select],
  "user_roles" => [:select],
  "users" => [:select],
  "way_nodes" => [:select, :insert],
  "way_tags" => [:select, :insert],
  "ways" => [:select, :insert]
}.freeze

PLANETDUMP_PERMISSIONS = {
  "note_comments" => :select,
  "notes" => :select,
  "users" => :select
}.freeze

PLANETDIFF_PERMISSIONS = {
  "changeset_comments" => :select,
  "changeset_tags" => :select,
  "changesets" => :select,
  "node_tags" => :select,
  "nodes" => :select,
  "relation_members" => :select,
  "relation_tags" => :select,
  "relations" => :select,
  "users" => :select,
  "way_nodes" => :select,
  "way_tags" => :select,
  "ways" => :select
}.freeze

PROMETHEUS_PERMISSIONS = {
  "delayed_jobs" => :select
}.freeze

%w[
  acls
  active_storage_attachments
  active_storage_blobs
  active_storage_variant_records
  ar_internal_metadata
  changeset_comments
  changeset_tags
  changesets
  changesets_subscribers
  current_node_tags
  current_nodes
  current_relation_members
  current_relation_tags
  current_relations
  current_way_nodes
  current_way_tags
  current_ways
  delayed_jobs
  diary_comments
  diary_entries
  diary_entry_subscriptions
  friends
  gps_points
  gpx_file_tags
  gpx_files
  issue_comments
  issues
  languages
  messages
  node_tags
  nodes
  note_comments
  notes
  oauth_access_grants
  oauth_access_tokens
  oauth_applications
  oauth_openid_requests
  redactions
  relation_members
  relation_tags
  relations
  reports
  schema_migrations
  user_blocks
  user_mutes
  user_preferences
  user_roles
  users
  way_nodes
  way_tags
  ways
].each do |table|
  postgresql_table table do
    cluster node[:db][:cluster]
    database "openstreetmap"
    owner "openstreetmap"
    permissions "openstreetmap" => [:all],
                "rails" => [:select, :insert, :update, :delete],
                "cgimap" => CGIMAP_PERMISSIONS[table],
                "planetdump" => PLANETDUMP_PERMISSIONS[table],
                "planetdiff" => PLANETDIFF_PERMISSIONS[table],
                "prometheus" => PROMETHEUS_PERMISSIONS[table],
                "backup" => [:select]
  end
end

%w[
  acls_id_seq
  active_storage_attachments_id_seq
  active_storage_blobs_id_seq
  active_storage_variant_records_id_seq
  changeset_comments_id_seq
  changesets_id_seq
  current_nodes_id_seq
  current_relations_id_seq
  current_ways_id_seq
  delayed_jobs_id_seq
  diary_comments_id_seq
  diary_entries_id_seq
  friends_id_seq
  gpx_file_tags_id_seq
  gpx_files_id_seq
  issue_comments_id_seq
  issues_id_seq
  messages_id_seq
  note_comments_id_seq
  notes_id_seq
  oauth_access_grants_id_seq
  oauth_access_tokens_id_seq
  oauth_applications_id_seq
  oauth_openid_requests_id_seq
  redactions_id_seq
  reports_id_seq
  user_blocks_id_seq
  user_mutes_id_seq
  user_roles_id_seq
  users_id_seq
].each do |sequence|
  postgresql_sequence sequence do
    cluster node[:db][:cluster]
    database "openstreetmap"
    owner "openstreetmap"
    permissions "openstreetmap" => [:all],
                "rails" => [:usage],
                "cgimap" => CGIMAP_PERMISSIONS[sequence],
                "backup" => [:select]
  end
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
  remove_ipc false
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
  remove_ipc false
end

systemd_timer "yearly-reindex" do
  description "Yearly database reindex"
  on_calendar "Thu *-1-8..14 02:00"
end

service "yearly-reindex.timer" do
  action [:enable, :start]
end

template "/etc/prometheus/exporters/sql_rails.collector.yml" do
  source "sql_rails.yml.erb"
  owner "root"
  group "root"
  mode "0644"
end
