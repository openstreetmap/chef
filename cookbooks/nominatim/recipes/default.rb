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

include_recipe "accounts"
include_recipe "munin"
include_recipe "php::fpm"
include_recipe "prometheus"

basedir = data_bag_item("accounts", "nominatim")["home"]
email_errors = data_bag_item("accounts", "lonvia")["email"]

directory basedir do
  owner "nominatim"
  group "nominatim"
  mode "755"
  recursive true
end

directory node[:nominatim][:logdir] do
  owner "nominatim"
  group "nominatim"
  mode "755"
  recursive true
end

file "#{node[:nominatim][:logdir]}/query.log" do
  action :create_if_missing
  owner "www-data"
  group "adm"
  mode "664"
end

file "#{node[:nominatim][:logdir]}/update.log" do
  action :create_if_missing
  owner "nominatim"
  group "adm"
  mode "664"
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
  mode "700"
end

# NOTE: tablespaces must be exactly in the same location on each
#       Nominatim instance when replication is in use. Therefore
#       use symlinks to canonical directory locations.
node[:nominatim][:tablespaces].each do |name, location|
  directory location do
    owner "postgres"
    group "postgres"
    mode "700"
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
    mode "700"
  end

  template "/usr/local/bin/clean-db-nominatim" do
    source "clean-db-nominatim.erb"
    owner "root"
    group "root"
    mode "755"
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
  python3-dotenv
  python3-psutil
  python3-jinja2
  python3-icu
  python3-datrie
  php-pgsql
  php-intl
  php-symfony-dotenv
  ruby
  ruby-file-tail
  ruby-pg
]

source_directory = "#{basedir}/nominatim"
build_directory = "#{basedir}/bin"
ui_directory = "#{basedir}/ui"
qa_bin_directory = "#{basedir}/Nominatim-Data-Analyser"
qa_data_directory = "#{basedir}/qa-data"

directory build_directory do
  owner "nominatim"
  group "nominatim"
  mode "755"
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
  notifies :run, "execute[compile_nominatim]"
end

remote_file "#{source_directory}/data/country_osm_grid.sql.gz" do
  action :create_if_missing
  source "https://www.nominatim.org/data/country_grid.sql.gz"
  owner "nominatim"
  group "nominatim"
  mode "644"
end

execute "compile_nominatim" do
  action :nothing
  user "nominatim"
  cwd build_directory
  command "cmake #{source_directory} && make"
end

link "/usr/local/bin/nominatim" do
  to "#{build_directory}/nominatim"
end

template "#{source_directory}/.git/hooks/post-merge" do
  source "git-post-merge-hook.erb"
  owner "nominatim"
  group "nominatim"
  mode "755"
  variables :srcdir => source_directory,
            :builddir => build_directory,
            :dbname => node[:nominatim][:dbname]
end

template "#{build_directory}/.env" do
  source "nominatim.env.erb"
  owner "nominatim"
  group "nominatim"
  mode "664"
  variables :base_url => node[:nominatim][:state] == "off" ? node[:fqdn] : "nominatim.openstreetmap.org",
            :dbname => node[:nominatim][:dbname],
            :flatnode_file => node[:nominatim][:flatnode_file],
            :log_file => "#{node[:nominatim][:logdir]}/query.log",
            :tokenizer => node[:nominatim][:config][:tokenizer]
end

git ui_directory do
  action :sync
  repository node[:nominatim][:ui_repository]
  revision node[:nominatim][:ui_revision]
  user "nominatim"
  group "nominatim"
end

template "#{ui_directory}/dist/theme/config.theme.js" do
  source "ui-config.js.erb"
  owner "nominatim"
  group "nominatim"
  mode "664"
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
  mode "644"
end

external_data = [
  "wikimedia-importance.sql.gz",
  "gb_postcodes.csv.gz",
  "us_postcodes.csv.gz"
]

external_data.each do |fname|
  remote_file "#{build_directory}/#{fname}" do
    action :create
    source "https://www.nominatim.org/data/#{fname}"
    owner "nominatim"
    group "nominatim"
    mode "644"
  end
end

if node[:nominatim][:state] == "off"
  cron_d "nominatim-backup" do
    action :delete
  end

  cron_d "nominatim-vacuum-db" do
    action :delete
  end

  cron_d "nominatim-clean-db" do
    action :delete
  end

  systemd_timer "nominatim-update-maintenance-trigger" do
    action :delete
  end
else
  cron_d "nominatim-backup" do
    action node[:nominatim][:enable_backup] ? :create : :delete
    minute "0"
    hour "3"
    day "1"
    user "nominatim"
    command "/usr/local/bin/backup-nominatim"
    mailto email_errors
  end

  cron_d "nominatim-vacuum-db" do
    minute "20"
    hour "0"
    user "postgres"
    command "/usr/local/bin/vacuum-db-nominatim"
    mailto email_errors
  end

  cron_d "nominatim-clean-db" do
    action node[:nominatim][:state] == "master" ? :create : :delete
    minute "5"
    hour "*/4"
    user "postgres"
    command "/usr/local/bin/clean-db-nominatim"
    mailto email_errors
  end

  systemd_service "nominatim-update-maintenance-trigger" do
    description "Trigger maintenance tasks for Nominatim DB"
    exec_start "touch #{basedir}/status/update_maintenance"
    user "nominatim"
  end

  systemd_timer "nominatim-update-maintenance-trigger" do
    action :create
    description "Schedule maintenance tasks for Nominatim DB"
    on_calendar "*-*-* 02:03:00 UTC"
  end

  service "nominatim-update-maintenance-trigger" do
    action [:enable]
  end
end

template "#{source_directory}/utils/nominatim-update" do
  source "updater.erb"
  user "nominatim"
  group "nominatim"
  mode "755"
  variables :bindir => build_directory,
            :srcdir => source_directory,
            :logfile => "#{node[:nominatim][:logdir]}/update.log",
            :branch => node[:nominatim][:revision],
            :update_stop_file => "#{basedir}/status/updates_disabled",
            :update_maintenance_trigger => "#{basedir}/status/update_maintenance",
            :qabindir => qa_bin_directory,
            :qadatadir => qa_data_directory
end

template "/etc/init.d/nominatim-update" do
  source "updater.init.erb"
  user "nominatim"
  group "nominatim"
  mode "755"
  variables :source_directory => source_directory
end

%w[backup-nominatim vacuum-db-nominatim].each do |fname|
  template "/usr/local/bin/#{fname}" do
    source "#{fname}.erb"
    owner "root"
    group "root"
    mode "755"
    variables :db => node[:nominatim][:dbname]
  end
end

## webserver frontend

directory "#{basedir}/etc" do
  owner "nominatim"
  group "adm"
  mode "775"
end

%w[user_agent referrer email generic].each do |name|
  file "#{basedir}/etc/nginx_blocked_#{name}.conf" do
    action :create_if_missing
    owner "nominatim"
    group "adm"
    mode "664"
  end
end

node[:nominatim][:fpm_pools].each do |name, data|
  php_fpm name do
    port data[:port]
    pm data[:pm]
    pm_max_children data[:max_children]
    pm_start_servers 20
    pm_min_spare_servers 10
    pm_max_spare_servers 20
    pm_max_requests 10000
    prometheus_port data[:prometheus_port]
  end
end

ssl_certificate node[:fqdn] do
  domains [node[:fqdn],
           "nominatim.openstreetmap.org",
           "nominatim.osm.org",
           "nominatim.openstreetmap.com",
           "nominatim.openstreetmap.net",
           "nominatim.openstreetmaps.org",
           "nominatim.openmaps.org",
           "nominatim.qgis.org"]
  notifies :reload, "service[nginx]"
end

include_recipe "nginx"

nginx_site "default" do
  action [:delete]
end

frontends = search(:node, "recipes:web\\:\\:frontend").sort_by(&:name)

nginx_site "nominatim" do
  template "nginx.erb"
  directory build_directory
  variables :pools => node[:nominatim][:fpm_pools],
            :frontends => frontends,
            :confdir => "#{basedir}/etc",
            :ui_directory => ui_directory
end

template "/etc/logrotate.d/nginx" do
  source "logrotate.nginx.erb"
  owner "root"
  group "root"
  mode "644"
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

package "ruby-webrick"

prometheus_exporter "nominatim" do
  port 8082
  user "www-data"
  options [
    "--nominatim.query-log=#{node[:nominatim][:logdir]}/query.log",
    "--nominatim.database-name=#{node[:nominatim][:dbname]}"
  ]
end

directory "#{basedir}/status" do
  owner "nominatim"
  group "postgres"
  mode "775"
end

include_recipe "fail2ban"

frontend_addresses = frontends.collect { |f| f.ipaddresses(:role => :external) }

fail2ban_jail "nominatim_limit_req" do
  filter "nginx-limit-req"
  logpath "#{node[:nominatim][:logdir]}/nominatim.openstreetmap.org-error.log"
  ports [80, 443]
  maxretry 20
  ignoreips frontend_addresses.flatten.sort
end

### QA tile generation

if node[:nominatim][:enable_qa_tiles]
  package "python3-geojson"

  git qa_bin_directory do
    repository node[:nominatim][:qa_repository]
    revision node[:nominatim][:qa_revision]
    enable_submodules true
    user "nominatim"
    group "nominatim"
    notifies :run, "execute[compile_qa]"
  end

  execute "compile_qa" do
    action :nothing
    user "nominatim"
    cwd "#{qa_bin_directory}/clustering-vt"
    command "make"
  end

  directory qa_data_directory do
    owner "nominatim"
    group "nominatim"
    mode "755"
    recursive true
  end

  template "#{qa_bin_directory}/analyser/config/config.yaml" do
    source "qa_config.erb"
    owner "nominatim"
    group "nominatim"
    mode "755"
    variables :outputdir => "#{qa_data_directory}/new"
  end

  ssl_certificate "qa-tile.nominatim.openstreetmap.org" do
    domains ["qa-tile.nominatim.openstreetmap.org"]
    notifies :reload, "service[nginx]"
  end

  nginx_site "qa-tiles.nominatim" do
    template "nginx-qa-tiles.erb"
    directory build_directory
    variables :qa_data_directory => qa_data_directory
  end

end
