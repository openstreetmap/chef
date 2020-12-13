#
# Cookbook:: foundation
# Recipe:: owg
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

git "/srv/operations.osmfoundation.org" do
  action :sync
  repository "https://github.com/openstreetmap/owg-website.git"
  depth 1
  user "root"
  group "root"
  notifies :run, "execute[/srv/operations.osmfoundation.org/Gemfile]"
end

directory "/srv/operations.osmfoundation.org/_site" do
  mode "755"
  owner "nobody"
  group "nogroup"
end

# Workaround https://github.com/jekyll/jekyll/issues/7804
# by creating a .jekyll-cache folder
directory "/srv/operations.osmfoundation.org/.jekyll-cache" do
  mode "755"
  owner "nobody"
  group "nogroup"
end

execute "/srv/operations.osmfoundation.org/Gemfile" do
  action :nothing
  command "bundle install --deployment"
  cwd "/srv/operations.osmfoundation.org"
  user "root"
  group "root"
  notifies :run, "execute[/srv/operations.osmfoundation.org]"
end

execute "/srv/operations.osmfoundation.org" do
  action :nothing
  command "bundle exec jekyll build --trace"
  cwd "/srv/operations.osmfoundation.org"
  user "nobody"
  group "nogroup"
end

ssl_certificate "operations.osmfoundation.org" do
  domains "operations.osmfoundation.org"
  notifies :reload, "service[apache2]"
end

apache_site "operations.osmfoundation.org" do
  template "apache.owg.erb"
  directory "/srv/operations.osmfoundation.org/_site"
end
