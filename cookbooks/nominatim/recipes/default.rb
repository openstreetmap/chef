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

basedir = data_bag_item("accounts", "nominatim")["home"]
email_errors = data_bag_item("accounts", "lonvia")["email"]

directory basedir do
  owner "nominatim"
  group "nominatim"
  mode 0o755
  recursive true
end

directory node[:nominatim][:logdir] do
  owner "nominatim"
  group "nominatim"
  mode 0o755
  recursive true
end

file "#{node[:nominatim][:logdir]}/query.log" do
  action :create_if_missing
  owner "www-data"
  group "adm"
  mode 0o664
end

file "#{node[:nominatim][:logdir]}/update.log" do
  action :create_if_missing
  owner "nominatim"
  group "adm"
  mode 0o664
end

## Postgresql

include_recipe "postgresql"

package "postgis"

node[:nominatim][:dbadmins].each do |user|
  postgresql_user user do
    cluster node[:nominatim][:dbcluster]
    superuser true
    only_if { node[:nominatim][:state] != "slave" }
  end
end

postgresql_user "nominatim" do
  cluster node[:nominatim][:dbcluster]
  superuser true
  only_if { node[:nominatim][:state] != "slave" }
end

postgresql_user "www-data" do
  cluster node[:nominatim][:dbcluster]
  only_if { node[:nominatim][:state] != "slave" }
end

postgresql_munin "nominatim" do
  cluster node[:nominatim][:dbcluster]
  database node[:nominatim][:dbname]
end

directory "#{basedir}/tablespaces" do
  owner "postgres"
  group "postgres"
  mode 0o700
end

# Note: tablespaces must be exactly in the same location on each
#       Nominatim instance when replication is in use. Therefore
#       use symlinks to canonical directory locations.
node[:nominatim][:tablespaces].each do |name, location|
  directory location do
    owner "postgres"
    group "postgres"
    mode 0o700
    recursive true
  end

  link "#{basedir}/tablespaces/#{name}" do
    to location
  end

  postgresql_tablespace name do
    cluster node[:nominatim][:dbcluster]
    location "#{basedir}/tablespaces/#{name}"
  end
end

if node[:nominatim][:state] == "master" # ~FC023
  postgresql_user "replication" do
    cluster node[:nominatim][:dbcluster]
    password data_bag_item("nominatim", "passwords")["replication"]
    replication true
  end

  directory node[:rsyncd][:modules][:archive][:path] do
    owner "postgres"
    group "postgres"
    mode 0o700
  end

  template "/usr/local/bin/clean-db-nominatim" do
    source "clean-db-nominatim.erb"
    owner "root"
    group "root"
    mode 0o755
    variables :archive_dir => node[:rsyncd][:modules][:archive][:path],
              :update_stop_file => "#{basedir}/status/updates_disabled",
              :streaming_clients => search(:node, "nominatim_state:slave").map { |slave| slave[:fqdn] }.join(" ")
  end
end

## Nominatim backend

include_recipe "git"
include_recipe "python"

package "build-essential"
package "cmake"
package "g++"
package "libboost-dev"
package "libboost-system-dev"
package "libboost-filesystem-dev"
package "libboost-python-dev"
package "libexpat1-dev"
package "zlib1g-dev"
package "libxml2-dev"
package "libbz2-dev"
package "libpq-dev"
package "libgeos++-dev"
package "libproj-dev"
package "osmosis"

python_package "osmium"

source_directory = "#{basedir}/nominatim"
build_directory = "#{basedir}/bin"

directory build_directory do
  owner "nominatim"
  group "nominatim"
  mode 0o755
  recursive true
end

# Normally syncing via chef is a bad idea because syncing might involve
# an update of database functions which should not be done while an update
# is ongoing. Therefore we sync in between update cycles. There is an
# exception for slaves: they get DB function updates from the master, so
# only the source code needs to be updated, which chef may do.
git source_directory do
  action node[:nominatim][:state] == "slave" ? :sync : :checkout
  repository node[:nominatim][:repository]
  revision node[:nominatim][:revision]
  enable_submodules true
  user "nominatim"
  group "nominatim"
  notifies :run, "execute[compile_nominatim]", :immediately
end

execute "compile_nominatim" do
  action :nothing
  user "nominatim"
  cwd build_directory
  command "cmake #{source_directory} && make"
end

template "#{source_directory}/.git/hooks/post-merge" do
  source "git-post-merge-hook.erb"
  owner "nominatim"
  group "nominatim"
  mode 0o755
  variables :srcdir => source_directory,
            :builddir => build_directory,
            :dbname => node[:nominatim][:dbname]
end

template "#{build_directory}/settings/local.php" do
  source "settings.erb"
  owner "nominatim"
  group "nominatim"
  mode 0o664
  variables :base_url => node[:nominatim][:state] == "off" ? node[:fqdn] : "nominatim.openstreetmap.org",
            :dbname => node[:nominatim][:dbname],
            :flatnode_file => node[:nominatim][:flatnode_file],
            :log_file => "#{node[:nominatim][:logdir]}/query.log"
end

if node[:nominatim][:flatnode_file] # ~FC023
  directory File.dirname(node[:nominatim][:flatnode_file]) do
    recursive true
  end
end

template "/etc/logrotate.d/nominatim" do
  source "logrotate.nominatim.erb"
  owner "root"
  group "root"
  mode 0o644
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
    mode 0o644
  end
end

remote_file "#{source_directory}/data/country_osm_grid.sql.gz" do
  action :create_if_missing
  source "http://www.nominatim.org/data/country_grid.sql.gz"
  owner "nominatim"
  group "nominatim"
  mode 0o644
end

template "/etc/cron.d/nominatim" do
  action node[:nominatim][:state] == :off ? :delete : :create
  source "nominatim.cron.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :bin_directory => "#{source_directory}/utils", :mailto => email_errors
end

template "#{source_directory}/utils/nominatim-update" do
  source "updater.erb"
  user "nominatim"
  group "nominatim"
  mode 0o755
  variables :bindir => build_directory,
            :srcdir => source_directory,
            :logfile => "#{node[:nominatim][:logdir]}/update.log",
            :branch => node[:nominatim][:revision],
            :update_stop_file => "#{basedir}/status/updates_disabled"
end

template "/etc/init.d/nominatim-update" do
  source "updater.init.erb"
  user "nominatim"
  group "nominatim"
  mode 0o755
  variables :source_directory => source_directory
end

%w(backup-nominatim vacuum-db-nominatim).each do |fname|
  template "/usr/local/bin/#{fname}" do
    source "#{fname}.erb"
    owner "root"
    group "root"
    mode 0o755
    variables :db => node[:nominatim][:dbname]
  end
end

## webserver frontend

template "#{build_directory}/settings/ip_blocks.conf" do
  action :create_if_missing
  source "ipblocks.erb"
  owner "nominatim"
  group "nominatim"
  mode 0o664
end

file "#{build_directory}/settings/apache_blocks.conf" do
  action :create_if_missing
  owner "nominatim"
  group "nominatim"
  mode 0o664
end

file "#{build_directory}/settings/ip_blocks.map" do
  action :create_if_missing
  owner "nominatim"
  group "nominatim"
  mode 0o664
end

include_recipe "apache"

package "php"
package "php-fpm"
package "php-pgsql"
package "php-pear"
package "php-db"

apache_module "rewrite"
apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "proxy_http"
apache_module "headers"
apache_module "reqtimeout"

service "php7.0-fpm" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

node[:nominatim][:fpm_pools].each do |name, data|
  template "/etc/php/7.0/fpm/pool.d/#{name}.conf" do
    source "fpm.conf.erb"
    owner "root"
    group "root"
    mode 0o644
    variables data.merge(:name => name)
    notifies :reload, "service[php7.0-fpm]"
  end
end

ssl_certificate "nominatim.openstreetmap.org" do
  domains ["nominatim.openstreetmap.org",
           "nominatim.osm.org",
           "nominatim.openstreetmap.com",
           "nominatim.openstreetmap.net",
           "nominatim.openstreetmaps.org",
           "nominatim.openmaps.org"]
  notifies :reload, "service[apache2]"
end

apache_site "nominatim.openstreetmap.org" do
  template "apache.erb"
  directory build_directory
  variables :pools => node[:nominatim][:fpm_pools]
end

apache_site "default" do
  action [:disable]
end

template "/etc/logrotate.d/apache2" do
  source "logrotate.apache.erb"
  owner "root"
  group "root"
  mode 0o644
end

include_recipe "fail2ban"

web_servers = search(:node, "recipes:web\\:\\:frontend").collect do |n| # ~FC010
  n.ipaddresses(:role => :external)
end.flatten

fail2ban_filter "nominatim" do
  failregex '^<HOST> - - \[\] "[^"]+" (408|429) '
end

fail2ban_jail "nominatim" do
  filter "nominatim"
  logpath "/var/log/apache2/nominatim.openstreetmap.org-access.log"
  ports [80, 443]
  maxretry 100
  ignoreips web_servers
end

munin_plugin_conf "nominatim" do
  template "munin.erb"
  variables :db => node[:nominatim][:dbname],
            :querylog => "#{node[:nominatim][:logdir]}/query.log"
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

directory "#{basedir}/status" do
  owner "nominatim"
  group "postgres"
  mode 0o775
end
