#
# Cookbook:: blogs
# Recipe:: default
#
# Copyright:: 2016, OpenStreetMap Foundation
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
include_recipe "apache"
include_recipe "git"

package %w[
  ruby
  ruby-dev
  make
  gcc
  g++
  libsqlite3-dev
]

gem_package "bundler" do
  version "~> 1.17.2"
end

directory "/srv/blogs.openstreetmap.org" do
  owner "blogs"
  group "blogs"
  mode "755"
end

git "/srv/blogs.openstreetmap.org" do
  action :sync
  repository "https://github.com/gravitystorm/blogs.osm.org.git"
  depth 1
  user "blogs"
  group "blogs"
  notifies :run, "execute[/srv/blogs.openstreetmap.org/Gemfile]", :immediately
end

execute "/srv/blogs.openstreetmap.org/Gemfile" do
  action :nothing
  command "bundle install --deployment"
  cwd "/srv/blogs.openstreetmap.org"
  user "blogs"
  group "blogs"
  notifies :run, "execute[/srv/blogs.openstreetmap.org]", :immediately
end

execute "/srv/blogs.openstreetmap.org" do
  action :nothing
  command "bundle exec pluto build -t osm -o build"
  cwd "/srv/blogs.openstreetmap.org"
  user "blogs"
  group "blogs"
end

ssl_certificate "blogs.openstreetmap.org" do
  domains ["blogs.openstreetmap.org", "blogs.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "blogs.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/blogs.openstreetmap.org/build"
  variables :aliases => ["blogs.osm.org"]
end

template "/usr/local/bin/blogs-update" do
  source "blogs-update.erb"
  owner "root"
  group "root"
  mode "0755"
end

cron_d "blogs" do
  minute "*/30"
  user "blogs"
  command "/usr/local/bin/blogs-update"
  mailto "admins@openstreetmap.org"
end
