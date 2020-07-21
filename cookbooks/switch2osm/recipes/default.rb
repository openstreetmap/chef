#
# Cookbook:: switch2osm
# Recipe:: default
#
# Copyright:: 2013, OpenStreetMap Foundation
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

apache_module "expires"
apache_module "rewrite"

gem_package "bundler" do
  version "1.17.3"
end

git "/srv/switch2osm.org" do
  action :sync
  repository "https://github.com/switch2osm/switch2osm.github.io.git"
  depth 1
  user "root"
  group "root"
  notifies :run, "execute[/srv/switch2osm.org/Gemfile]"
end

directory "/srv/switch2osm.org/_site" do
  mode "755"
  owner "nobody"
  group "nogroup"
end

# Workaround https://github.com/jekyll/jekyll/issues/7804
# by creating a .jekyll-cache folder
directory "/srv/switch2osm.org/.jekyll-cache" do
  mode "755"
  owner "nobody"
  group "nogroup"
end

execute "/srv/switch2osm.org/Gemfile" do
  action :nothing
  command "bundle install --deployment"
  cwd "/srv/switch2osm.org"
  user "root"
  group "root"
  notifies :run, "execute[/srv/switch2osm.org]"
end

execute "/srv/switch2osm.org" do
  action :nothing
  command "bundle exec jekyll build --trace --config _config.yml,_config_osm.yml"
  cwd "/srv/switch2osm.org"
  user "nobody"
  group "nogroup"
end

ssl_certificate "switch2osm.org" do
  domains ["switch2osm.org",
           "www.switch2osm.org", "switch2osm.com", "www.switch2osm.com"]
  notifies :reload, "service[apache2]"
end

apache_site "switch2osm.org" do
  template "apache.erb"
  directory "/srv/switch2osm.org/_site"
end
