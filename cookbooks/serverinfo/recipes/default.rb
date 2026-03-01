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

include_recipe "accounts"
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

group "serverinfo" do
  gid 534
end

user "serverinfo" do
  uid 534
  gid 534
  comment "hardware.openstreetmap.org"
  home "/srv/hardware.openstreetmap.org"
  shell "/usr/sbin/nologin"
  manage_home false
end

directory "/srv/hardware.openstreetmap.org" do
  owner "serverinfo"
  group "serverinfo"
  mode "755"
end

git "/srv/hardware.openstreetmap.org" do
  action :sync
  repository "https://github.com/osmfoundation/osmf-server-info.git"
  depth 1
  user "serverinfo"
  group "serverinfo"
  notifies :run, "bundle_install[/srv/hardware.openstreetmap.org]"
end

nodes = { :rows => search(:node, "*:*") }
roles = { :rows => search(:role, "*:*") }

file "/srv/hardware.openstreetmap.org/_data/nodes.json" do
  content nodes.to_json
  mode "644"
  owner "serverinfo"
  group "serverinfo"
  notifies :run, "bundle_exec[/srv/hardware.openstreetmap.org]"
  sensitive true
end

file "/srv/hardware.openstreetmap.org/_data/roles.json" do
  content roles.to_json
  mode "644"
  owner "serverinfo"
  group "serverinfo"
  notifies :run, "bundle_exec[/srv/hardware.openstreetmap.org]"
end

bundle_config "/srv/hardware.openstreetmap.org" do
  action :create
  user "serverinfo"
  group "serverinfo"
  settings "deployment" => "true",
           "without" => "development:test",
           "jobs" => node.cpu_cores.to_s
  notifies :run, "bundle_exec[/srv/hardware.openstreetmap.org]"
end

bundle_install "/srv/hardware.openstreetmap.org" do
  action :nothing
  user "serverinfo"
  group "serverinfo"
  notifies :run, "bundle_exec[/srv/hardware.openstreetmap.org]"
end

bundle_exec "/srv/hardware.openstreetmap.org" do
  action :nothing
  command "jekyll build --trace --disable-disk-cache --baseurl=https://hardware.openstreetmap.org"
  user "serverinfo"
  group "serverinfo"
  environment "LANG" => "C.UTF-8"
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
