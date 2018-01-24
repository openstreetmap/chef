#
# Cookbook Name:: planet
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

package "perl"
package "pbzip2"
package "osmosis"

package "php-cli"

file "/etc/cron.d/planet" do
  action :delete
end

remote_directory "/store/planet#html" do
  path "/store/planet"
  source "html"
  owner "root"
  group "root"
  mode "0755"
  files_owner "root"
  files_group "root"
  files_mode 0o644
end

remote_directory "/store/planet#cgi" do
  path "/store/planet"
  source "cgi"
  owner "root"
  group "root"
  mode 0o755
  files_owner "root"
  files_group "root"
  files_mode 0o755
end

remote_directory node[:planet][:dump][:xml_history_directory] do
  source "history_cgi"
  owner "www-data"
  group "planet"
  mode 0o775
  files_owner "root"
  files_group "root"
  files_mode 0o755
end

remote_directory "/store/planet/cc-by-sa/full-experimental" do
  source "ccbysa_history_cgi"
  owner "www-data"
  group "planet"
  mode 0o775
  files_owner "root"
  files_group "root"
  files_mode 0o755
end

[:xml_directory, :xml_history_directory,
 :pbf_directory, :pbf_history_directory].each do |dir|
  directory node[:planet][:dump][dir] do
    owner "www-data"
    group "planet"
    mode 0o775
  end
end

directory "/store/planet/notes" do
  owner "www-data"
  group "planet"
  mode 0o775
end

template "/usr/local/bin/apache-latest-planet-filename" do
  source "apache-latest-planet-filename.erb"
  owner "root"
  group "root"
  mode 0o755
end

apache_module "cgid"
apache_module "rewrite"
apache_module "proxy_http"

ssl_certificate "planet.openstreetmap.org" do
  domains ["planet.openstreetmap.org", "planet.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "planet.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/logrotate.d/apache2" do
  source "logrotate.apache.erb"
  owner "root"
  group "root"
  mode 0o644
end

munin_plugin "planet_age"

template "/usr/local/bin/old-planet-file-cleanup" do
  source "old-planet-file-cleanup.erb"
  owner "root"
  group "root"
  mode 0o755
end

template "/etc/cron.d/old-planet-file-cleanup" do
  source "old-planet-file-cleanup.cron.erb"
  owner "root"
  group "root"
  mode 0o644
end
