#
# Cookbook:: imagery
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

include_recipe "nginx"
include_recipe "git"

# Imagery gdal Requirements
package "gdal-bin"
# python-gdal - disable while broken in gis unstable repo

# Imagery MapServer + Mapcache Requirements
package %w[
  cgi-mapserver
  mapcache-cgi
  mapcache-tools
]

# Mapserver via Nginx requires as fastcgi spawner
package %w[
  spawn-fcgi
  multiwatch
]

# Imagery processing Requirements
package "imagemagick"

# Imagery misc compression
package %w[
  xz-utils
  unzip
]

directory "/srv/imagery/mapserver" do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

directory "/srv/imagery/common" do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

directory "/srv/imagery/common/ostn02-ntv2-data" do
  owner "root"
  group "root"
  mode "755"
end

remote_file "#{Chef::Config[:file_cache_path]}/ostn02-ntv2-data.zip" do
  source "https://www.ordnancesurvey.co.uk/docs/gps/ostn02-ntv2-data.zip"
  not_if { ::File.exist?("/srv/imagery/common/ostn02-ntv2-data/OSTN02_NTv2.gsb") }
end

execute "unzip-ostn02-ntv2-data" do
  command "unzip -q #{Chef::Config[:file_cache_path]}/ostn02-ntv2-data.zip"
  cwd "/srv/imagery/common/ostn02-ntv2-data"
  user "root"
  group "root"
  not_if { ::File.exist?("/srv/imagery/common/ostn02-ntv2-data/OSTN02_NTv2.gsb") }
end

nginx_site "default" do
  template "nginx_default.conf.erb"
  directory "/srv/imagery/default"
end

systemd_tmpfile "/run/mapserver-fastcgi" do
  type "d"
  owner "imagery"
  group "imagery"
  mode "0755"
end
