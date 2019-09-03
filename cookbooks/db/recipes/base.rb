#
# Cookbook Name:: db
# Recipe:: base
#
# Copyright 2011, OpenStreetMap Foundation
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

include_recipe "postgresql"
include_recipe "git"
include_recipe "python"

passwords = data_bag_item("db", "passwords")
wal_secrets = data_bag_item("db", "wal-secrets")

postgresql_munin "openstreetmap" do
  cluster node["db"]["cluster"]
  database "openstreetmap"
end

directory "/srv/www.openstreetmap.org" do
  group "rails"
  mode "2775"
end

rails_port "www.openstreetmap.org" do
  ruby "2.5"
  directory "/srv/www.openstreetmap.org/rails"
  user "rails"
  group "rails"
  repository "https://git.openstreetmap.org/public/rails.git"
  revision "live"
  database_host "localhost"
  database_name "openstreetmap"
  database_username "openstreetmap"
  database_password passwords["openstreetmap"]
  gpx_dir "/store/rails/gpx"
end

db_version = node["db"]["cluster"].split("/").first
pg_config = "/usr/lib/postgresql/#{db_version}/bin/pg_config"
function_directory = "/srv/www.openstreetmap.org/rails/db/functions/#{db_version}"

directory function_directory do
  owner "rails"
  group "rails"
  mode "755"
end

execute function_directory do
  action :nothing
  command "make PG_CONFIG=#{pg_config} DESTDIR=#{function_directory}"
  cwd "/srv/www.openstreetmap.org/rails/db/functions"
  user "rails"
  group "rails"
  subscribes :run, "directory[#{function_directory}]"
  subscribes :run, "git[/srv/www.openstreetmap.org/rails]"
end

link "/usr/lib/postgresql/#{db_version}/lib/libpgosm.so" do
  to "#{function_directory}/libpgosm.so"
  owner "root"
  group "root"
end

package "lzop"

python_package "wal-e" do
  python_version "3"
end

python_package "boto" do
  python_version "3"
end

template "/usr/local/bin/openstreetmap-wal-e" do
  source "wal-e.erb"
  owner "root"
  group "postgres"
  mode "750"
  variables :s3_key => wal_secrets["s3_key"]
end
