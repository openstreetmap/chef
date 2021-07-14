#
# Cookbook:: community
# Recipe:: default
#
# Copyright:: 2021, OpenStreetMap Foundation
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

include_recipe "docker"
include_recipe "git"
include_recipe "ssl"

ssl_certificate "community.openstreetmap.org" do
  domains ["community.openstreetmap.org", "community.osm.org"]
end

# passwords = data_bag_item("community", "passwords")

# postgresql_user "community_user" do
#   cluster node[:db][:cluster]
#   password passwords["database"]
# end

# postgresql_database "community_db" do
#   cluster node[:db][:cluster]
#   owner "community_user"
# end

# postgresql_extension "hstore" do
#   cluster node[:db][:cluster]
#   database "community_db"
# end

# postgresql_extension "pg_trgm" do
#   cluster node[:db][:cluster]
#   database "community_db"
# end

directory "/srv/community.openstreetmap.org" do
  owner "root"
  group "root"
  mode "755"
end

directory "/srv/community.openstreetmap.org/shared" do
  owner "community"
  group "community"
  mode "755"
end

git "/srv/community.openstreetmap.org/docker" do
  action :sync
  repository "https://github.com/discourse/discourse_docker.git"
  revision "master"
  depth 1
  user "root"
  group "root"
end

# TBC: discourse docker templates
#   web.ssl.template.yml
#   redis.template.yml
# TBC: discourse launcher rebuild
