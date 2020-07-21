#
# Cookbook:: serverinfo
# Recipe:: default
#
# Copyright:: 2015, OpenStreetMap Foundation
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

include_recipe "apache"
include_recipe "git"

package %w[
  gcc
  g++
  make
  ruby
  ruby-dev
  libssl-dev
  zlib1g-dev
  pkg-config
]

gem_package "bundler" do
  version "1.17.3"
end

git "/srv/hardware.openstreetmap.org" do
  action :sync
  repository "https://github.com/gravitystorm/osmf-server-info.git"
  depth 1
  user "root"
  group "root"
  notifies :run, "execute[/srv/hardware.openstreetmap.org/Gemfile]"
end

nodes = { :rows => search(:node, "*:*") }
roles = { :rows => search(:role, "*:*") }

file "/srv/hardware.openstreetmap.org/_data/nodes.json" do
  content nodes.to_json
  mode "644"
  owner "root"
  group "root"
  notifies :run, "execute[/srv/hardware.openstreetmap.org]"
end

file "/srv/hardware.openstreetmap.org/_data/roles.json" do
  content roles.to_json
  mode "644"
  owner "root"
  group "root"
  notifies :run, "execute[/srv/hardware.openstreetmap.org]"
end

directory "/srv/hardware.openstreetmap.org/_site" do
  mode "755"
  owner "nobody"
  group "nogroup"
end

# Workaround https://github.com/jekyll/jekyll/issues/7804
# by creating a .jekyll-cache folder
directory "/srv/hardware.openstreetmap.org/.jekyll-cache" do
  mode "755"
  owner "nobody"
  group "nogroup"
end

execute "/srv/hardware.openstreetmap.org/Gemfile" do
  action :nothing
  command "bundle install --deployment"
  cwd "/srv/hardware.openstreetmap.org"
  user "root"
  group "root"
  notifies :run, "execute[/srv/hardware.openstreetmap.org]"
end

execute "/srv/hardware.openstreetmap.org" do
  action :nothing
  command "bundle exec jekyll build --trace --baseurl=https://hardware.openstreetmap.org"
  cwd "/srv/hardware.openstreetmap.org"
  user "nobody"
  group "nogroup"
end

ssl_certificate "hardware.openstreetmap.org" do
  domains ["hardware.openstreetmap.org", "hardware.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "hardware.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/hardware.openstreetmap.org/_site"
  variables :aliases => ["hardware.osm.org"]
end
