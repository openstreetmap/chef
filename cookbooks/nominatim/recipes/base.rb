#
# Cookbook Name:: nominatim
# Recipe:: base
#
# Copyright 2015, OpenStreetMap Foundation
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
include_recipe "postgresql"

package "php5"
package "php5-cli"
package "php5-pgsql"
package "php5-fpm"
package "php-pear"
package "php-apc"
package "php-db"

apache_module "rewrite"
apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "proxy_http"

home_directory = data_bag_item("accounts", "nominatim")["home"]
source_directory = "#{home_directory}/nominatim"
email_errors = data_bag_item("accounts", "lonvia")["email"]

database_cluster = node[:nominatim][:database][:cluster]
database_version = database_cluster.sub(%r{/.*}, "")
database_name = node[:nominatim][:database][:dbname]

postgis_version = node[:nominatim][:database][:postgis]

service "php5-fpm" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

node[:nominatim][:fpm_pools].each do |name, data|
  template "/etc/php5/fpm/pool.d/#{name}.conf" do
    source "fpm.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables data.merge(:name => name, :port => data[:port])
    notifies :reload, "service[php5-fpm]"
  end
end

postgresql_munin "nominatim" do
  cluster database_cluster
  database database_name
end

directory node[:nominatim][:logdir] do
  owner "nominatim"
  group "nominatim"
  mode 0755
  recursive true
end

file "#{node[:nominatim][:logdir]}/query.log" do
  action :create_if_missing
  owner "www-data"
  group "adm"
  mode 0664
end

file "#{node[:nominatim][:logdir]}/update.log" do
  action :create_if_missing
  owner "nominatim"
  group "adm"
  mode 0664
end

directory "#{home_directory}/status" do
  owner "nominatim"
  group "postgres"
  mode 0775
end

template "/etc/logrotate.d/nominatim" do
  source "logrotate.nominatim.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/logrotate.d/apache2" do
  source "logrotate.apache.erb"
  owner "root"
  group "root"
  mode 0644
end

package "osmosis"
package "gcc"
package "proj-bin"
package "libgeos-c1"
package "postgresql-#{database_version}-postgis-#{postgis_version}"
package "postgresql-server-dev-#{database_version}"
package "build-essential"
package "libxml2-dev"
package "libexpat-dev"
package "libgeos-dev"
package "libgeos++-dev"
package "libpq-dev"
package "libbz2-dev"
package "libtool"
package "automake"
package "libproj-dev"
package "libprotobuf-c0-dev"
package "protobuf-c-compiler"
package "python-psycopg2"
package "libboost-dev"
package "libboost-system-dev"
package "libboost-filesystem-dev"
package "libboost-thread-dev"

execute "compile_nominatim" do
  action :nothing
  command "cd #{source_directory} && ./autogen.sh && ./configure && make"
  user "nominatim"
end

template "#{source_directory}/.git/hooks/post-merge" do
  source "update_source.erb"
  owner "nominatim"
  group "nominatim"
  mode 0755
  variables :source_directory => source_directory
end

template "#{source_directory}/settings/local.php" do
  source "nominatim.erb"
  owner "nominatim"
  group "nominatim"
  mode 0664
  variables :postgres_version => database_version
end

template "#{source_directory}/settings/ip_blocks.conf" do
  action :create_if_missing
  source "ipblocks.erb"
  owner "nominatim"
  group "nominatim"
  mode 0664
end

file "#{source_directory}/settings/apache_blocks.conf" do
  action :create_if_missing
  owner "nominatim"
  group "nominatim"
  mode 0664
end

file "#{source_directory}/settings/ip_blocks.map" do
  action :create_if_missing
  owner "nominatim"
  group "nominatim"
  mode 0664
end

cron_action = if node[:nominatim][:enabled]
                :create
              else
                :delete
              end

template "/etc/cron.d/nominatim" do
  action cron_action
  source "cron.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :bin_directory => "#{source_directory}/utils", :mailto => email_errors
end

template "#{source_directory}/utils/nominatim-update" do
  source "updater.erb"
  user "nominatim"
  group "nominatim"
  mode 0755
end

template "/etc/init.d/nominatim-update" do
  source "updater.init.erb"
  user "nominatim"
  group "nominatim"
  mode 0755
  variables :source_directory => source_directory
end

munin_plugin_conf "nominatim" do
  template "munin.erb"
end

munin_plugin "nominatim_importlag" do
  target "#{source_directory}/munin/nominatim_importlag"
end

munin_plugin "nominatim_query_speed" do
  target "#{source_directory}/munin/nominatim_query_speed_querylog"
end

munin_plugin "nominatim_requests" do
  target "#{source_directory}/munin/nominatim_requests_querylog"
end

munin_plugin "nominatim_throttled_ips" do
  target "#{source_directory}/munin/nominatim_throttled_ips"
end

external_data = [
  "wikipedia_article.sql.bin",
  "wikipedia_redirect.sql.bin",
  "gb_postcode_data.sql.gz"
]

external_data.each do |fname|
  remote_file "#{source_directory}/data/#{fname}" do
    action :create_if_missing
    source "http://www.nominatim.org/data/#{fname}"
    owner "nominatim"
    group "nominatim"
    mode 0644
  end
end

additional_scripts = %w(backup-nominatim vacuum-db-nominatim)

additional_scripts.each do |fname|
  template "/usr/local/bin/#{fname}" do
    source "#{fname}.erb"
    owner "root"
    group "root"
    mode 0755
  end
end

directory File.dirname(node[:nominatim][:flatnode_file]) do
  owner "nominatim"
  group "nominatim"
  mode 0755
  recursive true
end

apache_site "nominatim.openstreetmap.org" do
  template "apache.erb"
  directory source_directory
  variables :pools => node[:nominatim][:fpm_pools]
end

apache_site "default" do
  action [:disable]
end

fail2ban_filter "nominatim" do
  failregex '^<HOST> - - \[[^]]+\] "[^"]+" 429 '
end

fail2ban_jail "nominatim" do
  filter "nominatim"
  logpath "/var/log/apache2/nominatim.openstreetmap.org-access.log"
  ports [80, 443]
  maxretry 100
end
