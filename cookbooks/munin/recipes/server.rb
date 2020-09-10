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

package "munin"
package "rrdcached"
package "libcgi-fast-perl"

template "/etc/default/rrdcached" do
  source "rrdcached.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/var/lib/munin/rrdcached" do
  owner "munin"
  group "munin"
  mode "755"
end

service "rrdcached" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/default/rrdcached]"
end

munin_plugin "rrdcached"

expiry_time = 14 * 86400

clients = search(:node, "recipes:munin\\:\\:default").sort_by(&:name)
frontends = search(:node, "recipes:web\\:\\:frontend").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.sort_by(&:name).map do |n|
  { :name => n.name.split(".").first, :interface => n.interfaces(:role => :external).first[:interface].tr(".", "_") }
end
tilecaches = search(:node, "roles:tilecache").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.sort_by(&:name).map do |n|
  { :name => n.name.split(".").first, :interface => n.interfaces(:role => :external).first[:interface].tr(".", "_") }
end
renderers = search(:node, "roles:tile").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.sort_by(&:name).map do |n|
  { :name => n.name.split(".").first, :interface => n.interfaces(:role => :external).first[:interface].tr(".", "_") }
end
geocoders = search(:node, "roles:nominatim").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.sort_by(&:name).map do |n|
  { :name => n.name.split(".").first, :interface => n.interfaces(:role => :external).first[:interface].tr(".", "_") }
end

template "/etc/munin/munin.conf" do
  source "munin.conf.erb"
  owner "root"
  group "root"
  mode "644"
  variables :expiry_time => expiry_time, :clients => clients,
            :frontends => frontends, :geocoders => geocoders,
            :tilecaches => tilecaches, :renderers => renderers
end

apache_module "fcgid"
apache_module "rewrite"
apache_module "headers"

remote_directory "/srv/munin.openstreetmap.org" do
  source "www"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "644"
end

# directory to put dumped files in
directory "/srv/munin.openstreetmap.org/dumps" do
  owner "www-data"
  group "www-data"
  mode "755"
end

ssl_certificate "munin.openstreetmap.org" do
  domains ["munin.openstreetmap.org", "munin.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "munin.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/cron.daily/munin-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end

munin_plugin "munin_stats"
munin_plugin "munin_update"
munin_plugin "munin_rrdcached"
