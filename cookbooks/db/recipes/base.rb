#
# Cookbook:: db
# Recipe:: base
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

include_recipe "accounts"
include_recipe "git"
include_recipe "postgresql"
include_recipe "python"

passwords = data_bag_item("db", "passwords")
wal_secrets = data_bag_item("db", "wal-secrets")

ruby_version = node[:passenger][:ruby_version]
db_version = node[:db][:cluster].split("/").first
pg_config = "/usr/lib/postgresql/#{db_version}/bin/pg_config"
function_directory = "/srv/www.openstreetmap.org/rails/db/functions/#{db_version}"

postgresql_munin "openstreetmap" do
  cluster node[:db][:cluster]
  database "openstreetmap"
end

directory "/srv/www.openstreetmap.org" do
  group "rails"
  mode "2775"
end

rails_port "www.openstreetmap.org" do
  ruby ruby_version
  directory "/srv/www.openstreetmap.org/rails"
  user "rails"
  group "rails"
  repository "https://git.openstreetmap.org/public/rails.git"
  revision "live"
  build_assets false
  database_host "localhost"
  database_name "openstreetmap"
  database_username "openstreetmap"
  database_password passwords["openstreetmap"]
  gpx_dir "/store/rails/gpx"
end

directory function_directory do
  owner "rails"
  group "rails"
  mode "755"
end

execute function_directory do
  action :nothing
  command "make BUNDLE=bundle#{ruby_version} PG_CONFIG=#{pg_config} DESTDIR=#{function_directory}"
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

package %w[
  cmake
  libosmium2-dev
  libprotozero-dev
  libboost-filesystem-dev
  libboost-program-options-dev
  libbz2-dev
  zlib1g-dev
  libexpat1-dev
  libyaml-cpp-dev
  libpqxx-dev
]

git "/opt/osmdbt" do
  action :sync
  repository "https://github.com/openstreetmap/osmdbt.git"
  revision "master"
  depth 1
  user "root"
  group "root"
end

directory "/opt/osmdbt/build-#{db_version}" do
  owner "root"
  group "root"
  mode "755"
end

execute "/opt/osmdbt/CMakeLists.txt" do
  action :nothing
  command "cmake -DPG_CONFIG=/usr/lib/postgresql/#{db_version}/bin/pg_config .."
  cwd "/opt/osmdbt/build-#{db_version}"
  user "root"
  group "root"
  subscribes :run, "git[/opt/osmdbt]"
end

execute "/opt/osmdbt/build-#{db_version}/postgresql-plugin/Makefile" do
  action :nothing
  command "make"
  cwd "/opt/osmdbt/build-#{db_version}/postgresql-plugin"
  user "root"
  group "root"
  subscribes :run, "execute[/opt/osmdbt/CMakeLists.txt]"
end

link "/usr/lib/postgresql/#{db_version}/lib/osm-logical.so" do
  to "/opt/osmdbt/build-#{db_version}/postgresql-plugin/osm-logical.so"
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
