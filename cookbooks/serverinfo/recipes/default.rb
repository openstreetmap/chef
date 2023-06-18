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
include_recipe "ruby"

package %w[
  gcc
  g++
  make
  libssl-dev
  zlib1g-dev
  pkg-config
]

git "/srv/hardware.openstreetmap.org" do
  action :sync
  repository "https://github.com/osmfoundation/osmf-server-info.git"
  depth 1
  user "root"
  group "root"
  notifies :run, "bundle_install[/srv/hardware.openstreetmap.org]"
end

nodes = { :rows => search(:node, "*:*") }
roles = { :rows => search(:role, "*:*") }

file "/srv/hardware.openstreetmap.org/_data/nodes.json" do
  content nodes.to_json
  mode "644"
  owner "root"
  group "root"
  notifies :run, "bundle_exec[/srv/hardware.openstreetmap.org]"
end

file "/srv/hardware.openstreetmap.org/_data/roles.json" do
  content roles.to_json
  mode "644"
  owner "root"
  group "root"
  notifies :run, "bundle_exec[/srv/hardware.openstreetmap.org]"
end

directory "/srv/hardware.openstreetmap.org/_site" do
  mode "755"
  owner "nobody"
  group "nogroup"
end

directory "/srv/hardware.openstreetmap.org/vendor" do
  action :create
  owner "nobody"
  group "nogroup"
  notifies :run, "bundle_install[/srv/hardware.openstreetmap.org]", :immediately
end

bundle_install "/srv/hardware.openstreetmap.org" do
  action :nothing
  user "nobody"
  group "nogroup"
  environment "BUNDLE_FROZEN" => "true",
              "BUNDLE_WITHOUT" => "development:test",
              "BUNDLE_PATH" => "vendor/bundle",
              "BUNDLE_DEPLOYMENT" => "1",
              "BUNDLE_JOBS" => node.cpu_cores.to_s
  notifies :run, "bundle_exec[/srv/hardware.openstreetmap.org]"
end

bundle_exec "/srv/hardware.openstreetmap.org" do
  action :nothing
  command "jekyll build --trace --disable-disk-cache --baseurl=https://hardware.openstreetmap.org"
  user "nobody"
  group "nogroup"
  environment "LANG" => "C.UTF-8",
              "BUNDLE_PATH" => "vendor/bundle",
              "BUNDLE_DEPLOYMENT" => "1"
end

ssl_certificate "hardware.openstreetmap.org" do
  domains ["hardware.openstreetmap.org", "hardware.osm.org", "hardware.osmfoundation.org"]
  notifies :reload, "service[apache2]"
end

apache_site "hardware.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/hardware.openstreetmap.org/_site"
  variables :aliases => ["hardware.osm.org", "hardware.osmfoundation.org"]
end
