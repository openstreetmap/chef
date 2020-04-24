#
# Cookbook:: nominatim
# Recipe:: base
#
# Copyright:: 2015, OpenStreetMap Foundation
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

include_recipe "munin"

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

# exception granted for a limited time so that they can set up their own server
firewall_rule "increase-limits-gnome-proxy" do
  action :accept
  family "inet"
  source "net:8.43.85.23"
  dest "fw"
  proto "tcp:syn"
  dest_ports "https"
  rate_limit "s:10/sec:30"
end

## Postgresql

include_recipe "postgresql"

postgresql_version = node[:nominatim][:dbcluster].split("/").first
postgis_version = node[:nominatim][:postgis]

package "postgresql-#{postgresql_version}-postgis-#{postgis_version}"

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

if node[:nominatim][:state] == "master"
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

package %w[
  build-essential
  cmake
  g++
  libboost-dev
  libboost-system-dev
  libboost-filesystem-dev
  libexpat1-dev
  zlib1g-dev
  libxml2-dev
  libbz2-dev
  libpq-dev
  libgeos++-dev
  libproj-dev
  python3-pyosmium
  pyosmium
  python3-psycopg2
  php
  php-fpm
  php-pgsql
  php-intl
]

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
  not_if { node[:nominatim][:state] != "slave" && File.exist?("#{source_directory}/README.md") }
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

if node[:nominatim][:flatnode_file]
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
  "wikimedia-importance.sql.gz",
  "gb_postcode_data.sql.gz"
]

external_data.each do |fname|
  remote_file "#{source_directory}/data/#{fname}" do
    action :create_if_missing
    source "https://www.nominatim.org/data/#{fname}"
    owner "nominatim"
    group "nominatim"
    mode 0o644
  end
end

remote_file "#{source_directory}/data/country_osm_grid.sql.gz" do
  action :create_if_missing
  source "https://www.nominatim.org/data/country_grid.sql.gz"
  owner "nominatim"
  group "nominatim"
  mode 0o644
end

template "/etc/cron.d/nominatim" do
  action node[:nominatim][:state] == "off" ? :delete : :create
  source "nominatim.cron.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :bin_directory => "#{source_directory}/utils",
            :mailto => email_errors,
            :update_maintenance_trigger => "#{basedir}/status/update_maintenance"
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
            :update_stop_file => "#{basedir}/status/updates_disabled",
            :update_maintenance_trigger => "#{basedir}/status/update_maintenance"
end

template "/etc/init.d/nominatim-update" do
  source "updater.init.erb"
  user "nominatim"
  group "nominatim"
  mode 0o755
  variables :source_directory => source_directory
end

%w[backup-nominatim vacuum-db-nominatim].each do |fname|
  template "/usr/local/bin/#{fname}" do
    source "#{fname}.erb"
    owner "root"
    group "root"
    mode 0o755
    variables :db => node[:nominatim][:dbname]
  end
end

## webserver frontend

directory "#{basedir}/etc" do
  owner "nominatim"
  group "adm"
  mode 0o775
end

file "#{basedir}/etc/nginx_blocked_user_agent.conf" do
  action :create_if_missing
  owner "nominatim"
  group "adm"
  mode 0o664
end

file "#{basedir}/etc/nginx_blocked_referrer.conf" do
  action :create_if_missing
  owner "nominatim"
  group "adm"
  mode 0o664
end

service "php7.2-fpm" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

node[:nominatim][:fpm_pools].each do |name, data|
  template "/etc/php/7.2/fpm/pool.d/#{name}.conf" do
    source "fpm.conf.erb"
    owner "root"
    group "root"
    mode 0o644
    variables data.merge(:name => name)
    notifies :reload, "service[php7.2-fpm]"
  end
end

ssl_certificate node[:fqdn] do
  domains [node[:fqdn],
           "nominatim.openstreetmap.org",
           "nominatim.osm.org",
           "nominatim.openstreetmap.com",
           "nominatim.openstreetmap.net",
           "nominatim.openstreetmaps.org",
           "nominatim.openmaps.org"]
  notifies :reload, "service[nginx]"
end

package "apache2" do
  action :remove
end

include_recipe "nginx"

nginx_site "default" do
  action [:delete]
end

nginx_site "nominatim" do
  template "nginx.erb"
  directory build_directory
  variables :pools => node[:nominatim][:fpm_pools],
            :confdir => "#{basedir}/etc"
end

template "/etc/logrotate.d/nginx" do
  source "logrotate.nginx.erb"
  owner "root"
  group "root"
  mode 0o644
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

directory "#{basedir}/status" do
  owner "nominatim"
  group "postgres"
  mode 0o775
end
