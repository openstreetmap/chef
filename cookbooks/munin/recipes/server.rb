#
# Cookbook:: munin
# Recipe:: server
#
# Copyright:: 2010, OpenStreetMap Foundation
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

file "/etc/default/rrdcached" do
  action :delete
end

directory "/var/lib/munin/rrdcached" do
  action :delete
  recursive true
end

service "rrdcached" do
  action [:stop, :disable]
end

file "/etc/munin/munin.conf" do
  action :delete
end

directory "/srv/munin.openstreetmap.org" do
  action :delete
  recursive true
end

ssl_certificate "munin.openstreetmap.org" do
  action :delete
end

apache_site "munin.openstreetmap.org" do
  action :delete
end

file "/etc/cron.daily/munin-backup" do
  action :delete
end

package "munin" do
  action :purge
end

package "rrdcached" do
  action :purge
end

package "libcgi-fast-perl" do
  action :purge
end
