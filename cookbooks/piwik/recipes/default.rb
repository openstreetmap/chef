#
# Cookbook Name:: piwik
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
include_recipe "mysql"

passwords = data_bag_item("piwik", "passwords")

package "php5"
package "php5-cli"
package "php5-curl"
package "php5-mysql"
package "php5-gd"

package "php-apc"

package "geoip-database-contrib"

apache_module "php5"
apache_module "geoip"

apache_site "piwik.openstreetmap.org" do
  template "apache.erb"
end

directory "/srv/piwik.openstreetmap.org" do
  owner "root"
  group "root"
  mode "0755"
end

directory "/srv/piwik.openstreetmap.org/config" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

directory "/srv/piwik.openstreetmap.org/tmp" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

template "/etc/cron.d/piwiki" do
  source "cron.erb"
  owner "root"
  group "root"
  mode "0644"
end

mysql_user "piwik@localhost" do
  password passwords["database"]
end

mysql_database "piwik" do
  permissions "piwik@localhost" => :all
end
