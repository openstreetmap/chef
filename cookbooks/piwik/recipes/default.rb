#
# Cookbook:: piwik
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

include_recipe "apache"
include_recipe "mysql"

passwords = data_bag_item("piwik", "passwords")

package "php"
package "php-cli"
package "php-curl"
package "php-mbstring"
package "php-mysql"
package "php-gd"
package "php-xml"
package "php-apcu"

package "geoipupdate"

apache_module "expires"
apache_module "php7.2"
apache_module "rewrite"

version = node["piwik"]["version"]

directory "/opt/piwik-#{version}" do
  owner "root"
  group "root"
  mode "0755"
end

remote_file "#{Chef::Config[:file_cache_path]}/piwik-#{version}.zip" do
  source "https://builds.matomo.org/piwik-#{version}.zip"
  not_if { File.exist?("/opt/piwik-#{version}/piwik") }
end

execute "unzip-piwik-#{version}" do
  command "unzip -q #{Chef::Config[:file_cache_path]}/piwik-#{version}.zip"
  cwd "/opt/piwik-#{version}"
  user "root"
  group "root"
  not_if { File.exist?("/opt/piwik-#{version}/piwik") }
end

execute "/opt/piwik-#{version}/piwik/piwik.js" do
  command "gzip -k -9 /opt/piwik-#{version}/piwik/piwik.js"
  cwd "/opt/piwik-#{version}"
  user "root"
  group "root"
  not_if { File.exist?("/opt/piwik-#{version}/piwik/piwik.js.gz") }
end

directory "/opt/piwik-#{version}/piwik/config" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

template "/opt/piwik-#{version}/piwik/config/config.ini.php" do
  source "config.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :passwords => passwords,
            :directory => "/opt/piwik-#{version}/piwik",
            :plugins => node["piwik"]["plugins"]
end

directory "/opt/piwik-#{version}/piwik/tmp" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

link "/opt/piwik-#{version}/piwik/misc/GeoLite2-ASN.mmdb" do
  to "/var/lib/GeoIP/GeoLite2-ASN.mmdb"
end

link "/opt/piwik-#{version}/piwik/misc/GeoLite2-City.mmdb" do
  to "/var/lib/GeoIP/GeoLite2-City.mmdb"
end

link "/opt/piwik-#{version}/piwik/misc/GeoLite2-Country.mmdb" do
  to "/var/lib/GeoIP/GeoLite2-Country.mmdb"
end

link "/srv/piwik.openstreetmap.org" do
  to "/opt/piwik-#{version}/piwik"
  notifies :restart, "service[apache2]"
end

mysql_user "piwik@localhost" do
  password passwords["database"]
end

mysql_database "piwik" do
  permissions "piwik@localhost" => :all
end

ssl_certificate "piwik.openstreetmap.org" do
  domains ["piwik.openstreetmap.org", "piwik.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "piwik.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/cron.d/piwiki" do
  source "cron.erb"
  owner "root"
  group "root"
  mode "0644"
end
