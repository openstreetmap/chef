#
# Cookbook:: gps-tile
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

include_recipe "accounts"
include_recipe "apache"
include_recipe "git"
include_recipe "memcached"

package %w[
  make
  build-essential
  pkg-config
  zlib1g-dev
  libbz2-dev
  libarchive-dev
  libexpat1-dev
  libpng-dev
  pngquant
  libcache-memcached-perl
]

directory "/srv/gps-tile.openstreetmap.org" do
  owner "gpstile"
  group "gpstile"
  mode "755"
end

git "/srv/gps-tile.openstreetmap.org/import" do
  action :sync
  repository "https://github.com/ericfischer/gpx-import.git"
  revision "live"
  depth 1
  user "gpstile"
  group "gpstile"
end

execute "/srv/gps-tile.openstreetmap.org/import/src/Makefile" do
  action :nothing
  command "make DB=none LDFLAGS=-lm"
  cwd "/srv/gps-tile.openstreetmap.org/import/src"
  user "gpstile"
  group "gpstile"
  subscribes :run, "git[/srv/gps-tile.openstreetmap.org/import]"
end

git "/srv/gps-tile.openstreetmap.org/datamaps" do
  action :sync
  repository "https://github.com/ericfischer/datamaps.git"
  revision "live"
  depth 1
  user "gpstile"
  group "gpstile"
end

execute "/srv/gps-tile.openstreetmap.org/datamaps/Makefile" do
  action :nothing
  command "make"
  cwd "/srv/gps-tile.openstreetmap.org/datamaps"
  user "gpstile"
  group "gpstile"
  subscribes :run, "git[/srv/gps-tile.openstreetmap.org/datamaps]"
end

git "/srv/gps-tile.openstreetmap.org/updater" do
  action :sync
  repository "https://github.com/ericfischer/gpx-updater.git"
  revision "live"
  depth 1
  user "gpstile"
  group "gpstile"
end

systemd_service "gps-update" do
  description "GPS tile update daemon"
  after ["network.target", "memcached.service"]
  wants ["memcached.service"]
  user "gpstile"
  working_directory "/srv/gps-tile.openstreetmap.org"
  exec_start "/srv/gps-tile.openstreetmap.org/updater/update"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  no_new_privileges true
  restart "on-failure"
end

service "gps-update" do
  action [:enable, :start]
  subscribes :restart, "git[/srv/gps-tile.openstreetmap.org/updater]"
  subscribes :restart, "systemd_service[gps-update]"
end

remote_directory "/srv/gps-tile.openstreetmap.org/html" do
  source "html"
  owner "gpstile"
  group "gpstile"
  mode "755"
  files_owner "gpstile"
  files_group "gpstile"
  files_mode "644"
end

apache_module "headers"
apache_module "rewrite"

ssl_certificate "gps-tile.openstreetmap.org" do
  domains ["gps-tile.openstreetmap.org",
           "a.gps-tile.openstreetmap.org",
           "b.gps-tile.openstreetmap.org",
           "c.gps-tile.openstreetmap.org",
           "gps.tile.openstreetmap.org",
           "gps-a.tile.openstreetmap.org",
           "gps-b.tile.openstreetmap.org",
           "gps-c.tile.openstreetmap.org"]
  notifies :reload, "service[apache2]"
end

apache_site "gps-tile.openstreetmap.org" do
  template "apache.erb"
end
