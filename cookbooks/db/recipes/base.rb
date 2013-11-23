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
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "postgresql"
include_recipe "git"

passwords = data_bag_item("db", "passwords")

postgresql_munin "openstreetmap" do
  cluster node[:db][:cluster]
  database "openstreetmap"
end

directory "/srv/www.openstreetmap.org" do
  group "rails"
  mode 02775
end

rails_port "www.openstreetmap.org" do
  directory "/srv/www.openstreetmap.org/rails"
  user "rails"
  group "rails"
  repository "git://git.openstreetmap.org/rails.git"
  revision "live"
  database_host "localhost"
  database_name "openstreetmap"
  database_username "openstreetmap"
  database_password passwords["openstreetmap"]
  gpx_dir "/store/rails/gpx"
  file_column_root "/store/rails"
end

execute "/srv/www.openstreetmap.org/rails/db/functions/Makefile" do
  action :nothing
  command "make"
  cwd "/srv/www.openstreetmap.org/rails/db/functions"
  user "rails"
  group "rails"
  subscribes :run, "git[/srv/www.openstreetmap.org/rails]"
end
