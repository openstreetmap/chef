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
  brotli
  gzip
  php-cli
  php-curl
  php-mbstring
  php-mysql
  php-gd
  php-xml
  php-apcu
]

apache_module "expires"
apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "rewrite"

version = node[:matomo][:version]

geoip_directory = node[:geoipupdate][:directory]

remote_file "#{Chef::Config[:file_cache_path]}/matomo-#{version}.zip" do
  source "https://builds.matomo.org/matomo-#{version}.zip"
end

archive_file "#{Chef::Config[:file_cache_path]}/matomo-#{version}.zip" do
  destination "/opt/matomo-#{version}"
  notifies :run, "notify_group[matomo-updated]"
end

node[:matomo][:plugins].each do |plugin_name, plugin_version|
  next if plugin_version.nil?

  remote_file "#{Chef::Config[:file_cache_path]}/matomo-#{plugin_name}-#{plugin_version}.zip" do
    source "https://plugins.matomo.org/api/2.0/plugins/#{plugin_name}/download/#{plugin_version}"
  end

  archive_file "#{Chef::Config[:file_cache_path]}/matomo-#{plugin_name}-#{plugin_version}.zip" do
    destination "/opt/matomo-#{plugin_name}-#{plugin_version}"
  end

  link "/opt/matomo-#{version}/matomo/plugins/#{plugin_name}" do
    to "/opt/matomo-#{plugin_name}-#{plugin_version}/#{plugin_name}"
    notifies :run, "notify_group[matomo-updated]"
  end
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
  notifies :run, "notify_group[matomo-updated]"
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

directory "/opt/matomo-#{version}/matomo/tmp/cache" do
  owner "www-data"
  group "www-data"
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

mysql_user "piwik@localhost" do
  password passwords["database"]
end

mysql_database "piwik" do
  permissions "piwik@localhost" => :all
end

notify_group "matomo-updated"

if File.symlink?("/srv/matomo.openstreetmap.org")
  execute "core:update" do
    action :nothing
    command "/opt/matomo-#{version}/matomo/console core:update --yes"
    user "www-data"
    group "www-data"
    subscribes :run, "notify_group[matomo-updated]"
  end

  execute "custom-matomo-js:update" do
    action :nothing
    command "/opt/matomo-#{version}/matomo/console custom-matomo-js:update"
    user "root"
    group "root"
    subscribes :run, "execute[core:update]"
  end

  execute "/opt/matomo-#{version}/matomo/matomo.br" do
    action :nothing
    command "brotli --keep --force --best /opt/matomo-#{version}/matomo/matomo.js"
    cwd "/opt/matomo-#{version}"
    user "root"
    group "root"
    subscribes :run, "execute[custom-matomo-js:update]"
  end

  execute "/opt/matomo-#{version}/matomo/matomo.js" do
    action :nothing
    command "gzip --keep --force --best /opt/matomo-#{version}/matomo/matomo.js"
    cwd "/opt/matomo-#{version}"
    user "root"
    group "root"
    subscribes :run, "execute[custom-matomo-js:update]"
  end

  execute "/opt/matomo-#{version}/matomo/piwik.br" do
    action :nothing
    command "brotli --keep --force --best /opt/matomo-#{version}/matomo/piwik.js"
    cwd "/opt/matomo-#{version}"
    user "root"
    group "root"
    subscribes :run, "execute[custom-matomo-js:update]"
  end

  execute "/opt/matomo-#{version}/matomo/piwik.js" do
    action :nothing
    command "gzip --keep --force --best /opt/matomo-#{version}/matomo/piwik.js"
    cwd "/opt/matomo-#{version}"
    user "root"
    group "root"
    subscribes :run, "execute[custom-matomo-js:update]"
  end
end

link "/srv/matomo.openstreetmap.org" do
  to "/opt/matomo-#{version}/matomo"
  notifies :restart, "service[php#{node[:php][:version]}-fpm]"
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

systemd_service "matomo-archive" do
  description "Matomo report archiving"
  exec_start "/usr/bin/php /srv/matomo.openstreetmap.org/console core:archive --url=https://matomo.openstreetmap.org/"
  user "www-data"
  sandbox true
  proc_subset "all"
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
  read_write_paths "/opt/matomo-#{version}/matomo/tmp"
end

systemd_timer "matomo-archive" do
  description "Matomo report archiving"
  on_boot_sec "30m"
  on_unit_inactive_sec "30m"
end

service "matomo-archive.timer" do
  action [:enable, :start]
end
