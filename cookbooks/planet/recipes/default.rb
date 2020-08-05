#
# Cookbook:: planet
# Recipe:: default
#
# Copyright:: 2011, OpenStreetMap Foundation
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
include_recipe "munin"

package %w[
  perl
  php-cli
]

remote_directory "/store/planet#html" do
  path "/store/planet"
  source "html"
  owner "root"
  group "root"
  mode "0755"
  files_owner "root"
  files_group "root"
  files_mode "644"
end

remote_directory "/store/planet#cgi" do
  path "/store/planet"
  source "cgi"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

remote_directory node[:planet][:dump][:xml_history_directory] do
  source "history_cgi"
  owner "www-data"
  group "planet"
  mode "775"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

remote_directory "/store/planet/cc-by-sa/full-experimental" do
  source "ccbysa_history_cgi"
  owner "www-data"
  group "planet"
  mode "775"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

[:xml_directory, :xml_history_directory,
 :pbf_directory, :pbf_history_directory].each do |dir|
  directory node[:planet][:dump][dir] do
    owner "www-data"
    group "planet"
    mode "775"
  end
end

directory "/store/planet/notes" do
  owner "www-data"
  group "planet"
  mode "775"
end

template "/usr/local/bin/apache-latest-planet-filename" do
  source "apache-latest-planet-filename.erb"
  owner "root"
  group "root"
  mode "755"
  notifies :restart, "service[apache2]"
end

apache_module "cgid"
apache_module "rewrite"
apache_module "proxy_http"
apache_module "ratelimit"

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
  mode "644"
end

munin_plugin "planet_age"

template "/usr/local/bin/old-planet-file-cleanup" do
  source "old-planet-file-cleanup.erb"
  owner "root"
  group "root"
  mode "755"
end

cron_d "old-planet-file-cleanup" do
  comment "run this on the first monday of the month at 3:44am"
  minute "44"
  hour "3"
  day "1-7"
  user "www-data"
  command "test $(date +\\%u) -eq 1 && /usr/local/bin/old-planet-file-cleanup --debug"
  mailto "zerebubuth@gmail.com"
end
