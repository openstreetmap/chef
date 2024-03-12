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
include_recipe "ruby"

passwords = data_bag_item("db", "passwords")
wal_secrets = data_bag_item("db", "wal-secrets")

directory "/srv/www.openstreetmap.org" do
  group "rails"
  mode "2775"
end

rails_port "www.openstreetmap.org" do
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
  revision "v0.5"
  depth 1
  user "root"
  group "root"
end

node[:postgresql][:versions].each do |db_version|
  directory "/opt/osmdbt/build-#{db_version}" do
    owner "root"
    group "root"
    mode "755"
  end

  execute "/opt/osmdbt/build-#{db_version}" do
    action :nothing
    command "cmake -DPG_CONFIG=/usr/lib/postgresql/#{db_version}/bin/pg_config .."
    cwd "/opt/osmdbt/build-#{db_version}"
    user "root"
    group "root"
    subscribes :run, "directory[/opt/osmdbt/build-#{db_version}]"
    subscribes :run, "git[/opt/osmdbt]"
  end

  execute "/opt/osmdbt/build-#{db_version}/postgresql-plugin/Makefile" do
    action :nothing
    command "make"
    cwd "/opt/osmdbt/build-#{db_version}/postgresql-plugin"
    user "root"
    group "root"
    subscribes :run, "execute[/opt/osmdbt/build-#{db_version}]"
  end

  link "/usr/lib/postgresql/#{db_version}/lib/osm-logical.so" do
    to "/opt/osmdbt/build-#{db_version}/postgresql-plugin/osm-logical.so"
    owner "root"
    group "root"
  end
end

package "lzop"

remote_file "/usr/local/bin/wal-g" do
  action :create
  source "https://github.com/wal-g/wal-g/releases/download/v2.0.1/wal-g-pg-ubuntu-20.04-amd64"
  owner "root"
  group "root"
  mode "755"
end

template "/usr/local/bin/openstreetmap-wal-g" do
  source "wal-g.erb"
  owner "root"
  group "postgres"
  mode "750"
  variables :s3_key => wal_secrets["s3_key"]
end
