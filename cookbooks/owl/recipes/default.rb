#
# Cookbook Name:: owl
# Recipe:: default
#
# Copyright 2012, OpenStreetMap Foundation
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

include_recipe "apache"
include_recipe "postgresql"

package "python"
package "python-psycopg2"

package "libxslt-dev"

package "ruby#{node[:owl][:ruby]}"
package "ruby#{node[:owl][:ruby]}-dev"
package "rubygems#{node[:owl][:ruby]}"
package "irb#{node[:owl][:ruby]}"

gem_package "bundler#{node[:owl][:ruby]}" do
  package_name "bundler"
  gem_binary "gem#{node[:owl][:ruby]}"
  options "--format-executable"
end

apache_module "deflate"

apache_module "passenger" do
  conf "passenger.conf.erb"
end

munin_plugin "passenger_memory"
munin_plugin "passenger_processes"
munin_plugin "passenger_queues"
munin_plugin "passenger_requests"

postgresql_user "tomh" do
  cluster "9.1/main"
  superuser true
end

postgresql_user "matt" do
  cluster "9.1/main"
  superuser true
end

postgresql_user "ppawel" do
  cluster "9.1/main"
  superuser true
end

postgresql_user "owl" do
  cluster "9.1/main"
end

postgresql_database "owl" do
  cluster "9.1/main"
  owner "owl"
end

postgresql_munin "owl" do
  cluster "9.1/main"
  database "owl"
end

# grant select on changeset_tiles to owl;
# grant select on geometry_columns to owl;
# grant select on changesets to owl;
# grant select on users to owl;

directory "/srv/owl.openstreetmap.org" do
  owner "owl"
  group "owl"
  mode 02775
end

file "/srv/owl.openstreetmap.org/openstreetmap-watch-list/rails/tmp/restart.txt" do
  action :nothing
end

execute "/srv/owl.openstreetmap.org/openstreetmap-watch-list/rails/Gemfile" do
  action :nothing
  command "bundle#{node[:owl][:ruby]} install"
  cwd "/srv/owl.openstreetmap.org/openstreetmap-watch-list/rails"
  user "root"
  group "root"
  notifies :touch, "file[/srv/owl.openstreetmap.org/openstreetmap-watch-list/rails/tmp/restart.txt]"
end

git "/srv/owl.openstreetmap.org/openstreetmap-watch-list" do
  action :sync
  repository "git://github.com/ppawel/openstreetmap-watch-list.git"
  revision "owl.osm.org"
  user "owl"
  group "owl"
  notifies :run, "execute[/srv/owl.openstreetmap.org/openstreetmap-watch-list/rails/Gemfile]"
end

directory "srv/owl.openstreetmap.org/openstreetmap-watch-list/rails/tmp" do
  owner "owl"
  group "owl"
end

file "srv/owl.openstreetmap.org/openstreetmap-watch-list/rails/config/environment.rb" do
  owner "owl"
  group "owl"
end

template "/srv/owl.openstreetmap.org/openstreetmap-watch-list/rails/config/database.yml" do
  source "database.yml.erb"
  owner "owl"
  group "owl"
  mode 0664
  notifies :run, "execute[/srv/owl.openstreetmap.org/openstreetmap-watch-list/rails/Gemfile]"
  only_if { node[:postgresql][:clusters][:"9.1/main"] }
end

apache_site "owl.openstreetmap.org" do
  template "apache.erb"
  variables :aliases => ["owl.osm.org"]
end
