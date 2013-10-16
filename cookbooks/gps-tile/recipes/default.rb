#
# Cookbook Name:: gps-tile
# Recipe:: default
#
# Copyright 2013, OpenStreetMap Foundation
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

package "make"
package "build-essential"
package "pkg-config"
package "zlib1g-dev"
package "libbz2-dev"
package "libarchive-dev"
package "libexpat1-dev"
package "libpng-dev"
package "pngquant"
package "libcache-memcached-perl"

directory "/srv/gps-tile.openstreetmap.org" do
  owner "gpstile"
  group "gpstile"
  mode 0755
end

git "/srv/gps-tile.openstreetmap.org/import" do
  action :sync
  repository "git://github.com/ericfischer/gpx-import.git"
  revision "master"
  user "gpstile"
  group "gpstile"
end

execute "/srv/gps-tile.openstreetmap.org/import/src/Makefile" do
  action :nothing
  command "make"
  cwd "/srv/gps-tile.openstreetmap.org/import/src"
  user "gpstile"
  group "gpstile"
  subscribes :run, "git[/srv/gps-tile.openstreetmap.org/import]"
end

git "/srv/gps-tile.openstreetmap.org/datamaps" do
  action :sync
  repository "git://github.com/ericfischer/datamaps.git"
  revision "master"
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
  repository "git://github.com/ericfischer/gpx-updater.git"
  revision "master"
  user "gpstile"
  group "gpstile"
end

template "/etc/init.d/gps-update" do
  source "update.init.erb"
  owner "root"
  group "root"
  mode 0755
end

service "gps-update" do
  action [ :enable, :start ]
  supports :restart => true
  subscribes :restart, "git[/srv/gps-tile.openstreetmap.org/updater]"
end

remote_directory "/srv/gps-tile.openstreetmap.org/html" do
  source "html"
  owner "gpstile"
  group "gpstile"
  mode 0755
  files_owner "gpstile"
  files_group "gpstile"
  files_mode 0644
end

apache_module "headers"

apache_site "gps-tile.openstreetmap.org" do
  template "apache.erb"
end
