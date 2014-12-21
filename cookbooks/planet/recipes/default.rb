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

include_recipe "apache::ssl"

package "perl"
package "php5-cli"
package "pbzip2"
package "osmosis"

remote_directory "/usr/local/bin" do
  source "bin"
  owner "root"
  group "root"
  mode 0755
  files_owner "root"
  files_group "root"
  files_mode 0755
end

template "/etc/cron.d/planet" do
  source "cron.erb"
  owner "root"
  group "root"
  mode 0644
end

remote_directory "/store/planet" do
  source "html"
  owner "root"
  group "root"
  mode "0755"
  files_owner "root"
  files_group "root"
  files_mode 0644
end

remote_directory "/store/planet" do
  source "cgi"
  owner "root"
  group "root"
  mode 0755
  files_owner "root"
  files_group "root"
  files_mode 0755
end

[:xml_directory, :xml_history_directory,
 :pbf_directory, :pbf_history_directory].each do |dir|
  directory dir do
    owner "www-data"
    group "planet"
    mode 0775
  end
end

directory "/store/planet/notes" do
  owner "www-data"
  group "planet"
  mode 0775
end

apache_module "rewrite"
apache_module "proxy_http"

apache_site "planet.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/logrotate.d/apache2" do
  source "logrotate.apache.erb"
  owner "root"
  group "root"
  mode 0644
end
