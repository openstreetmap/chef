#
# Cookbook Name:: munin
# Recipe:: server
#
# Copyright 2010, OpenStreetMap Foundation
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

package "munin"
package "rrdcached"
package "libcgi-fast-perl"

template "/etc/default/rrdcached" do
  source "rrdcached.erb"
  owner "root"
  group "root"
  mode 0o644
end

directory "/var/lib/munin/rrdcached" do
  owner "munin"
  group "munin"
  mode 0o755
end

service "rrdcached" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/default/rrdcached]"
end

munin_plugin "rrdcached"

expiry_time = 14 * 86400

clients = search(:node, "recipes:munin\\:\\:default").sort_by { |n| n[:hostname] } # ~FC010
frontends = search(:node, "recipes:web\\:\\:frontend").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.map { |n| n[:hostname] }.sort # ~FC010
backends = search(:node, "recipes:web\\:\\:backend").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.map { |n| n[:hostname] }.sort # ~FC010
tilecaches = search(:node, "roles:tilecache").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.sort_by { |n| n[:hostname] }.map do |n|
  { :name => n[:hostname], :interface => n.interfaces(:role => :external).first[:interface] }
end
renderers = search(:node, "roles:tile").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.sort_by { |n| n[:hostname] }.map do |n|
  { :name => n[:hostname], :interface => n.interfaces(:role => :external).first[:interface] }
end
geocoders = search(:node, "roles:nominatim").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.sort_by { |n| n[:hostname] }.map do |n|
  { :name => n[:hostname], :interface => n.interfaces(:role => :external).first[:interface] }
end

template "/etc/munin/munin.conf" do
  source "munin.conf.erb"
  owner "root"
  group "root"
  mode 0o644
  variables :expiry_time => expiry_time, :clients => clients,
            :frontends => frontends, :backends => backends,
            :tilecaches => tilecaches, :renderers => renderers,
            :geocoders => geocoders
end

apache_module "fcgid"
apache_module "rewrite"
apache_module "headers"

remote_directory "/srv/munin.openstreetmap.org" do
  source "www"
  owner "root"
  group "root"
  mode 0o755
  files_owner "root"
  files_group "root"
  files_mode 0o644
  purge true
end

apache_site "munin.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/cron.daily/munin-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0o755
end

munin_plugin "munin_stats"
munin_plugin "munin_update"
munin_plugin "munin_rrdcached"
