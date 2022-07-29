#
# Cookbook:: matomo
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
include_recipe "geoipupdate"
include_recipe "mysql"
include_recipe "php::fpm"

passwords = data_bag_item("matomo", "passwords")

package %w[
  php-cli
  php-curl
  php-mbstring
  php-mysql
  php-gd
  php-xml
  php-apcu
]

apache_module "expires"
apache_module "rewrite"

version = node[:matomo][:version]

geoip_directory = node[:geoipupdate][:directory]

directory "/opt/matomo-#{version}" do
  owner "root"
  group "root"
  mode "0755"
end

remote_file "#{Chef::Config[:file_cache_path]}/matomo-#{version}.zip" do
  source "https://builds.matomo.org/matomo-#{version}.zip"
  not_if { ::File.exist?("/opt/matomo-#{version}/matomo") }
end

archive_file "#{Chef::Config[:file_cache_path]}/matomo-#{version}.zip" do
  destination "/opt/matomo-#{version}"
  overwrite true
  owner "root"
  group "root"
  not_if { ::File.exist?("/opt/matomo-#{version}/matomo") }
end

node[:matomo][:plugins].each do |plugin_name, plugin_version|
  next if plugin_version.nil?

  remote_file "#{Chef::Config[:file_cache_path]}/matomo-#{plugin_name}-#{plugin_version}.zip" do
    source "https://plugins.matomo.org/api/2.0/plugins/#{plugin_name}/download/#{plugin_version}"
  end

  archive_file "#{Chef::Config[:file_cache_path]}/matomo-#{plugin_name}-#{plugin_version}.zip" do
    action :nothing
    destination "/opt/matomo-#{version}/matomo/plugins"
    overwrite true
    owner "root"
    group "root"
    subscribes :extract, "remote_file[#{Chef::Config[:file_cache_path]}/matomo-#{plugin_name}-#{plugin_version}.zip]", :immediately
  end
end

execute "/opt/matomo-#{version}/matomo/matomo.js" do
  command "gzip -k -9 /opt/matomo-#{version}/matomo/matomo.js"
  cwd "/opt/matomo-#{version}"
  user "root"
  group "root"
  not_if { ::File.exist?("/opt/matomo-#{version}/matomo/matomo.js.gz") }
end

execute "/opt/matomo-#{version}/matomo/piwik.js" do
  command "gzip -k -9 /opt/matomo-#{version}/matomo/piwik.js"
  cwd "/opt/matomo-#{version}"
  user "root"
  group "root"
  not_if { ::File.exist?("/opt/matomo-#{version}/matomo/piwik.js.gz") }
end

directory "/opt/matomo-#{version}/matomo/config" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

template "/opt/matomo-#{version}/matomo/config/config.ini.php" do
  source "config.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :passwords => passwords,
            :directory => "/opt/matomo-#{version}/matomo",
            :plugins => node[:matomo][:plugins].keys.sort
end

directory "/opt/matomo-#{version}/matomo/tmp" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

directory "/opt/matomo-#{version}/matomo/tmp/assets" do
  owner "www-data"
  group "mysql"
  mode "0750"
end

link "/opt/matomo-#{version}/matomo/misc/GeoLite2-ASN.mmdb" do
  to "#{geoip_directory}/GeoLite2-ASN.mmdb"
end

link "/opt/matomo-#{version}/matomo/misc/GeoLite2-City.mmdb" do
  to "#{geoip_directory}/GeoLite2-City.mmdb"
end

link "/opt/matomo-#{version}/matomo/misc/GeoLite2-Country.mmdb" do
  to "#{geoip_directory}/GeoLite2-Country.mmdb"
end

link "/srv/matomo.openstreetmap.org" do
  to "/opt/matomo-#{version}/matomo"
  notifies :restart, "service[php#{node[:php][:version]}-fpm]"
end

mysql_user "piwik@localhost" do
  password passwords["database"]
end

mysql_database "piwik" do
  permissions "piwik@localhost" => :all
end

ssl_certificate "matomo.openstreetmap.org" do
  domains ["matomo.openstreetmap.org", "matomo.osm.org",
           "piwik.openstreetmap.org", "piwik.osm.org"]
  notifies :reload, "service[apache2]"
end

php_fpm "matomo.openstreetmap.org" do
  prometheus_port 9253
end

apache_site "matomo.openstreetmap.org" do
  template "apache.erb"
end

cron_d "matomo" do
  minute "5"
  user "www-data"
  command "/usr/bin/php /srv/matomo.openstreetmap.org/console core:archive --quiet --url=https://matomo.openstreetmap.org/"
end

cron_d "piwik" do
  action :delete
end
