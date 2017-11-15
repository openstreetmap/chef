#
# Cookbook Name:: blogs
# Recipe:: default
#
# Copyright 2016, OpenStreetMap Foundation
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
include_recipe "git"

package %w[
  ruby
  ruby-dev
  make
  gcc
  libsqlite3-dev
]

gem_package "bundler"

directory "/srv/blogs.openstreetmap.org" do
  owner "blogs"
  group "blogs"
  mode 0o755
end

git "/srv/blogs.openstreetmap.org" do
  action :sync
  repository "git://github.com/gravitystorm/blogs.osm.org.git"
  user "blogs"
  group "blogs"
  notifies :run, "execute[/srv/blogs.openstreetmap.org/Gemfile]", :immediate
end

execute "/srv/blogs.openstreetmap.org/Gemfile" do
  action :nothing
  command "bundle install"
  cwd "/srv/blogs.openstreetmap.org"
  user "root"
  group "root"
  notifies :run, "execute[/srv/blogs.openstreetmap.org]", :immediate
end

execute "/srv/blogs.openstreetmap.org" do
  action :nothing
  command "/usr/local/bin/pluto build -t osm -o build"
  cwd "/srv/blogs.openstreetmap.org"
  user "blogs"
  group "blogs"
end

ssl_certificate "blogs.openstreetmap.org" do
  domains "blogs.openstreetmap.org"
  notifies :reload, "service[apache2]"
end

apache_site "blogs.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/blogs.openstreetmap.org/build"
end

template "/etc/cron.d/blogs" do
  source "cron.erb"
  owner "root"
  group "root"
  mode "0644"
end
