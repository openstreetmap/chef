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
include_recipe "geoipupdate"
include_recipe "planet::aws"

package %w[
  python3
  python3-geoip2
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
  owner "planet"
  group "planet"
  mode "775"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

remote_directory "/store/planet/cc-by-sa" do
  source "ccbysa_cgi"
  owner "planet"
  group "planet"
  mode "775"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

remote_directory "/store/planet/cc-by-sa/full-experimental" do
  source "ccbysa_history_cgi"
  owner "planet"
  group "planet"
  mode "775"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

[:xml_directory, :xml_history_directory,
 :pbf_directory, :pbf_history_directory].each do |dir|
  directory node[:planet][:dump][dir] do
    owner "planet"
    group "planet"
    mode "775"
  end
end

directory "/store/planet/notes" do
  owner "planet"
  group "planet"
  mode "775"
end

directory "/store/planet/statistics" do
  owner "planet"
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

template "/usr/local/bin/apache-s3-ip2region" do
  source "apache-s3-ip2region.erb"
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

template "/usr/local/bin/planet-file-cleanup" do
  source "planet-file-cleanup.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "planet-file-cleanup" do
  description "Cleanup old planet files"
  exec_start "/usr/local/bin/planet-file-cleanup --debug"
  user "planet"
  sandbox true
  read_write_paths [
    node[:planet][:dump][:xml_directory],
    node[:planet][:dump][:pbf_directory]
  ]
end

systemd_timer "planet-file-cleanup" do
  description "Cleanup old planet files"
  on_calendar "Mon *-*-1..7 03:44"
end

service "planet-file-cleanup.timer" do
  action [:enable, :start]
end
