#
# Cookbook:: glitchtip
# Recipe:: default
#
# Copyright:: 2026, OpenStreetMap Foundation
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

include_recipe "podman::apache"
include_recipe "postgresql"
include_recipe "valkey"

glitchtip_passwords = data_bag_item("glitchtip", "passwords")
valkey_passwords = data_bag_item("valkey", "passwords")

database_cluster = node[:glitchtip][:database_cluster]
database_name = node[:glitchtip][:database_name]
database_user = node[:glitchtip][:database_user]
database_password = glitchtip_passwords[node[:glitchtip][:database_password]]

postgresql_user database_user do
  cluster database_cluster
  password database_password
end

postgresql_database database_name do
  cluster database_cluster
  owner database_user
end

directory "/srv/glitchtip.openstreetmap.org/uploads" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
end

database_url = "postgres://#{database_user}:#{database_password}@host.containers.internal:5432/#{database_name}"

valkey_password = valkey_passwords["glitchtip"]
valkey_url = "redis://glitchtip:#{valkey_password}@host.containers.internal:6379"

podman_site "glitchtip.openstreetmap.org" do
  image "docker.io/glitchtip/glitchtip:6"
  port 8000
  aliases ["glitchtip.osm.org"]
  environment "DATABASE_URL" => database_url,
              "VALKEY_URL" => valkey_url,
              "SECRET_KEY" => glitchtip_passwords["secret"],
              "EMAIL_URL" => "smtp://host.containers.internal:25",
              "DEFAULT_FROM_EMAIL" => "admins@openstreetmap.org",
              "ALLOWED_HOSTS" => "glitchtip.openstreetmap.org,glitchtip.osm.org",
              "ENABLE_ADMIN" => "False",
              "ENABLE_OBSERVABILITY_API" => "True",
              "ENABLE_OPENAPI" => "False",
              "GLITCHTIP_DOMAIN" => "https://glitchtip.openstreetmap.org",
              "GLITCHTIP_ENABLE_DUCKDB" => "False",
              "GLITCHTIP_ENABLE_MCP" => "False",
              "GLITCHTIP_INSTANCE_NAME" => "OpenStreetMap\\'s GlitchTip",
              "SERVER_ROLE" => "all_in_one"
  volumes "/srv/glitchtip.openstreetmap.org/uploads" => "/code/uploads"
end
