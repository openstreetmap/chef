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

aws_credentials = data_bag_item("db", "aws")

package %w[
  cmake
  g++
  libboost-filesystem-dev
  libboost-program-options-dev
  libbz2-dev
  libexpat1-dev
  libosmium2-dev
  libpqxx-dev
  libprotozero-dev
  libyaml-cpp-dev
  make
  zlib1g-dev
]

git "/opt/osmdbt" do
  action :sync
  repository "https://github.com/openstreetmap/osmdbt.git"
  revision "v0.9"
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
  variables :aws_credentials => aws_credentials
  sensitive true
end
