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
include_recipe "prometheus"

if node[:nominatim][:api_flavour] == "php"
  include_recipe "php::fpm"
end

basedir = data_bag_item("accounts", "nominatim")["home"]
email_errors = data_bag_item("accounts", "lonvia")["email"]

directory basedir do
  owner "nominatim"
  group "nominatim"
  mode "755"
  recursive true
end

## Log directory setup

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

## Nominatim backend

include_recipe "git"
include_recipe "python"

python_directory = "#{basedir}/venv"

package %w[
  build-essential
  cmake
  g++
  libboost-dev
  libboost-system-dev
  libboost-filesystem-dev
  libexpat1-dev
  zlib1g-dev
  libbz2-dev
  libpq-dev
  libproj-dev
  liblua5.3-dev
  libluajit-5.1-dev
  libicu-dev
  nlohmann-json3-dev
  lua5.3
  python3-pyosmium
  python3-psycopg2
  python3-dotenv
  python3-psutil
  python3-jinja2
  python3-icu
  python3-datrie
  python3-yaml
  python3-sqlalchemy-ext
  python3-geoalchemy2
  python3-asyncpg
  python3-dev
  pkg-config
  ruby
  ruby-file-tail
  ruby-pg
  ruby-webrick
]

if node[:nominatim][:api_flavour] == "php"
  package %w[
    php-pgsql
    php-intl
  ]
elsif node[:nominatim][:api_flavour] == "python"

  python_virtualenv python_directory do
    interpreter "/usr/bin/python3"
  end

  python_package "SQLAlchemy" do
    python_virtualenv python_directory
    version "2.0.32"
  end

  python_package "PyICU" do
    python_virtualenv python_directory
    version "2.13.1"
  end

  python_package "psycopg[binary]" do
    python_virtualenv python_directory
    version "3.2.1"
  end

  python_package "psycopg2-binary" do
    python_virtualenv python_directory
    version "2.9.9"
  end

  python_package "python-dotenv" do
    python_virtualenv python_directory
    version "1.0.1"
  end

  python_package "pygments" do
    python_virtualenv python_directory
    version "2.18.0"
  end

  python_package "PyYAML" do
    python_virtualenv python_directory
    version "6.0.2"
  end

  python_package "falcon" do
    python_virtualenv python_directory
    version "3.1.3"
  end

  python_package "uvicorn" do
    python_virtualenv python_directory
    version "0.30.5"
  end

  python_package "gunicorn" do
    python_virtualenv python_directory
    version "22.0.0"
  end

  python_package "jinja2" do
    python_virtualenv python_directory
    version "3.1.4"
  end

  python_package "datrie" do
    python_virtualenv python_directory
    version "0.8.2"
  end

  python_package "psutil" do
    python_virtualenv python_directory
    version "6.0.0"
  end

  python_package "osmium" do
    python_virtualenv python_directory
    version "3.7.0"
  end
end

source_directory = "#{basedir}/src/nominatim"
build_directory = "#{basedir}/src/build"
project_directory = "#{basedir}/planet-project"
bin_directory = "#{basedir}/bin"
cfg_directory = "#{basedir}/etc"
ui_directory = "#{basedir}/ui"
qa_bin_directory = "#{basedir}/src/Nominatim-Data-Analyser"
qa_data_directory = "#{basedir}/qa-data"

[basedir, "#{basedir}/src", cfg_directory, bin_directory, build_directory, project_directory].each do |path|
  directory path do
    owner "nominatim"
    group "nominatim"
    mode "755"
    recursive true
  end
end

directory "#{bin_directory}/maintenance" do
  owner "nominatim"
  group "nominatim"
  mode "775"
end

if node[:nominatim][:flatnode_file]
  directory File.dirname(node[:nominatim][:flatnode_file]) do
    recursive true
  end
end

remote_directory "#{project_directory}/static-website" do
  source "website"
  owner "nominatim"
  group "nominatim"
  mode "755"
  files_owner "nominatim"
  files_group "nominatim"
  files_mode "644"
  purge false
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
  source "https://nominatim.org/data/country_grid.sql.gz"
  owner "nominatim"
  group "nominatim"
  mode "644"
end

execute "compile_nominatim" do
  action :nothing
  user "nominatim"
  cwd build_directory
  command "cmake #{source_directory} && make"
  notifies :run, "execute[install_nominatim]"
end

execute "install_nominatim" do
  action :nothing
  cwd build_directory
  command "make install"
end

# Project directory

template "#{project_directory}/.env" do
  source "nominatim.env.erb"
  owner "nominatim"
  group "nominatim"
  mode "664"
  variables :base_url => node[:nominatim][:state] == "off" ? node[:fqdn] : "nominatim.openstreetmap.org",
            :dbname => node[:nominatim][:dbname],
            :flatnode_file => node[:nominatim][:flatnode_file],
            :log_file => "#{node[:nominatim][:logdir]}/query.log",
            :tokenizer => node[:nominatim][:config][:tokenizer],
            :forward_dependencies => node[:nominatim][:config][:forward_dependencies],
            :pool_size => node[:nominatim][:api_pool_size],
            :query_timeout => node[:nominatim][:api_query_timeout],
            :request_timeout => node[:nominatim][:api_request_timeout]
end

remote_file "#{project_directory}/secondary_importance.sql.gz" do
  action :create_if_missing
  source "https://nominatim.org/data/wikimedia-secondary-importance.sql.gz"
  owner "nominatim"
  group "nominatim"
  mode "644"
end

remote_file "#{project_directory}/wikimedia-importance.sql.gz" do
  action :create_if_missing
  source "https://nominatim.org/data/wikimedia-importance.sql.gz"
  owner "nominatim"
  group "nominatim"
  mode "644"
end

%w[gb_postcodes.csv.gz us_postcodes.csv.gz].each do |fname|
  remote_file "#{project_directory}/#{fname}" do
    action :create
    source "https://nominatim.org/data/#{fname}"
    owner "nominatim"
    group "nominatim"
    mode "644"
  end
end

# Webserver + frontend

%w[user_agent referrer email generic].each do |name|
  file "#{cfg_directory}/nginx_blocked_#{name}.conf" do
    action :create_if_missing
    owner "nominatim"
    group "adm"
    mode "664"
  end
end

if node[:nominatim][:api_flavour] == "php"
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
elsif node[:nominatim][:api_flavour] == "python"
  systemd_service "nominatim" do
    description "Nominatim running as a gunicorn application"
    user "www-data"
    group "www-data"
    working_directory project_directory
    standard_output "append:#{node[:nominatim][:logdir]}/gunicorn.log"
    standard_error "inherit"
    exec_start "#{python_directory}/bin/gunicorn --max-requests 200000 -b unix:/run/gunicorn-nominatim.openstreetmap.org.sock -w #{node[:nominatim][:api_workers]} -k uvicorn.workers.UvicornWorker nominatim_api.server.falcon.server:run_wsgi"
    exec_reload "/bin/kill -s HUP $MAINPID"
    environment :PYTHONPATH => "/usr/local/lib/nominatim/lib-python/"
    kill_mode "mixed"
    timeout_stop_sec 5
    private_tmp true
    requires "nominatim.socket"
    after "network.target"
  end

  systemd_socket "nominatim" do
    description "Gunicorn socket for Nominatim"
    listen_stream "/run/gunicorn-nominatim.openstreetmap.org.sock"
    socket_user "www-data"
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
  directory project_directory
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

# Updates

%w[nominatim-update
   nominatim-update-source
   nominatim-update-refresh-db
   nominatim-update-data
   nominatim-daily-maintenance].each do |fname|
  template "#{bin_directory}/#{fname}" do
    source "#{fname}.erb"
    owner "nominatim"
    group "nominatim"
    mode "554"
    variables :bindir => bin_directory,
              :srcdir => source_directory,
              :builddir => build_directory,
              :projectdir => project_directory,
              :qabindir => qa_bin_directory,
              :qadatadir => qa_data_directory
  end
end

systemd_service "nominatim-update" do
  description "Update the Nominatim database"
  exec_start "#{bin_directory}/nominatim-update"
  restart "on-success"
  standard_output "append:#{node[:nominatim][:logdir]}/update.log"
  standard_error "inherit"
  working_directory project_directory
end

systemd_service "nominatim-update-maintenance-trigger" do
  description "Trigger daily maintenance tasks for Nominatim DB"
  exec_start "ln -sf #{bin_directory}/nominatim-daily-maintenance #{bin_directory}/maintenance/"
  user "nominatim"
end

systemd_timer "nominatim-update-maintenance-trigger" do
  action node[:nominatim][:state] != "off" ? :create : :delete
  description "Schedule daily maintenance tasks for Nominatim DB"
  on_calendar "*-*-* 02:03:00 UTC"
end

service "nominatim-update-maintenance-trigger" do
  action node[:nominatim][:state] != "off" ? :enable : :disable
end

# Nominatim UI

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

# Nominatim QA

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

# Replication

cron_d "nominatim-clean-db" do
  action node[:nominatim][:state] == "master" ? :create : :delete
  minute "5"
  hour "*/4"
  user "postgres"
  command "#{bin_directory}/clean-db-nominatim"
  mailto email_errors
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

  template "#{bin_directory}/clean-db-nominatim" do
    source "clean-db-nominatim.erb"
    owner "nominatim"
    group "nominatim"
    mode "755"
    variables :archive_dir => node[:rsyncd][:modules][:archive][:path],
              :update_stop_file => "#{basedir}/status/updates_disabled",
              :streaming_clients => search(:node, "nominatim_state:slave").map { |slave| slave[:fqdn] }.join(" ")
  end
end

# Maintenance

cron_d "nominatim-backup" do
  action (node[:nominatim][:enable_backup] && node[:nominatim][:state] != "off") ? :create : :delete
  minute "0"
  hour "3"
  day "1"
  user "nominatim"
  command "#{bin_directory}/backup-nominatim"
  mailto email_errors
end

cron_d "nominatim-vacuum-db" do
  action node[:nominatim][:state] != "off" ? :create : :delete
  minute "20"
  hour "0"
  user "postgres"
  command "#{bin_directory}/vacuum-db-nominatim"
  mailto email_errors
end

%w[backup-nominatim vacuum-db-nominatim].each do |fname|
  template "#{bin_directory}/#{fname}" do
    source "#{fname}.erb"
    owner "nominatim"
    group "nominatim"
    mode "755"
    variables :db => node[:nominatim][:dbname]
  end
end

# Logging

template "/etc/logrotate.d/nominatim" do
  source "logrotate.nominatim.erb"
  owner "root"
  group "root"
  mode "644"
end

# Monitoring
prometheus_exporter "nominatim" do
  port 8082
  user "www-data"
  restrict_address_families "AF_UNIX"
  options [
    "--nominatim.query-log=#{node[:nominatim][:logdir]}/query.log",
    "--nominatim.database-name=#{node[:nominatim][:dbname]}"
  ]
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
