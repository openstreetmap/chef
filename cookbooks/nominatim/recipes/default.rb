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
include_recipe "postgresql"
include_recipe "python"
include_recipe "nginx"
include_recipe "git"
include_recipe "fail2ban"

basedir = data_bag_item("accounts", "nominatim")["home"]
project_directory = "#{basedir}/planet-project"
bin_directory = "#{basedir}/bin"
cfg_directory = "#{basedir}/etc"
ui_directory = "#{basedir}/ui"
qa_data_directory = "#{basedir}/qa-data"

directory basedir do
  owner "nominatim"
  group "nominatim"
  mode "755"
  recursive true
end

[basedir, bin_directory, cfg_directory, project_directory, ui_directory].each do |path|
  directory path do
    owner "nominatim"
    group "nominatim"
    mode "755"
  end
end

if node[:nominatim][:flatnode_file]
  directory File.dirname(node[:nominatim][:flatnode_file]) do
    recursive true
  end
end

directory "#{bin_directory}/maintenance" do
  owner "nominatim"
  group "nominatim"
  mode "775"
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

### Postgresql

postgresql_version = node[:nominatim][:dbcluster].split("/").first
postgis_version = node[:nominatim][:postgis]

package "postgresql-#{postgresql_version}-postgis-#{postgis_version}"

node[:nominatim][:dbadmins].each do |user|
  postgresql_user user do
    cluster node[:nominatim][:dbcluster]
    superuser true
  end
end

postgresql_user "nominatim" do
  cluster node[:nominatim][:dbcluster]
  superuser true
end

postgresql_user "www-data" do
  cluster node[:nominatim][:dbcluster]
end

### Nominatim

python_directory = "#{basedir}/venv"

package %w[
  build-essential
  libicu-dev
  python3-dev
  pkg-config
  osm2pgsql
  ruby
  ruby-file-tail
  ruby-pg
  ruby-webrick
]

python_virtualenv python_directory do
  interpreter "/usr/bin/python3"
end

# These are updated during the database update.
python_package "nominatim-db" do
  python_virtualenv python_directory
  extra_index_url node[:nominatim][:pip_index]
end

python_package "nominatim-api" do
  python_virtualenv python_directory
  extra_index_url node[:nominatim][:pip_index]
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

template "#{project_directory}/.env" do
  source "nominatim.env.erb"
  owner "nominatim"
  group "nominatim"
  mode "664"
  variables :base_url => "nominatim.openstreetmap.org",
            :dbname => node[:nominatim][:dbname],
            :flatnode_file => node[:nominatim][:flatnode_file],
            :log_file => "#{node[:nominatim][:logdir]}/query.log",
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

remote_file "#{project_directory}/wikimedia-importance.csv.gz" do
  action :create_if_missing
  source "https://nominatim.org/data/wikimedia-importance.csv.gz"
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

systemd_service "nominatim" do
  description "Nominatim running as a gunicorn application"
  user "www-data"
  group "www-data"
  working_directory project_directory
  standard_output "append:#{node[:nominatim][:logdir]}/gunicorn.log"
  standard_error "inherit"
  exec_start "#{python_directory}/bin/gunicorn --max-requests 200000 -b unix:/run/gunicorn-nominatim.openstreetmap.org.sock -w #{node[:nominatim][:api_workers]} -k uvicorn.workers.UvicornWorker 'nominatim_api.server.falcon.server:run_wsgi()'"
  exec_reload "/bin/kill -s HUP $MAINPID"
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

nginx_site "default" do
  action [:delete]
end

frontends = search(:node, "recipes:web\\:\\:frontend").sort_by(&:name)

remote_file "#{Chef::Config[:file_cache_path]}/fastly-ip-list.json" do
  source "https://api.fastly.com/public-ip-list"
  compile_time true
  ignore_failure true
end

fastlyips = JSON.parse(IO.read("#{Chef::Config[:file_cache_path]}/fastly-ip-list.json"))

nginx_site "nominatim" do
  template "nginx.erb"
  directory project_directory
  variables :pools => node[:nominatim][:fpm_pools],
            :frontends => frontends,
            :fastly => fastlyips["addresses"] + fastlyips["ipv6_addresses"],
            :confdir => "#{basedir}/etc",
            :ui_directory => ui_directory
end

template "/etc/logrotate.d/nginx" do
  source "logrotate.nginx.erb"
  owner "root"
  group "root"
  mode "644"
end

### Import, update and maintenance scripts

%w[nominatim-update
   nominatim-update-data
   nominatim-update-refresh-db
   nominatim-daily-maintenance].each do |fname|
  template "#{bin_directory}/#{fname}" do
    source "#{fname}.erb"
    owner "nominatim"
    group "nominatim"
    mode "554"
    variables :bindir => bin_directory,
              :projectdir => project_directory,
              :venvprefix => "#{python_directory}/bin/",
              :qadatadir => qa_data_directory
  end
end

systemd_service "nominatim-update" do
  description "Update the Nominatim database"
  exec_start "#{bin_directory}/nominatim-update"
  restart "on-success"
  standard_output "journal"
  standard_error "inherit"
  working_directory project_directory
end

systemd_service "nominatim-update-maintenance-trigger" do
  description "Trigger daily maintenance tasks for Nominatim DB"
  exec_start "ln -sf #{bin_directory}/nominatim-daily-maintenance #{bin_directory}/maintenance/"
  user "nominatim"
end

systemd_timer "nominatim-update-maintenance-trigger" do
  action :create
  description "Schedule daily maintenance tasks for Nominatim DB"
  on_calendar "*-*-* 02:03:00 UTC"
end

service "nominatim-update-maintenance-trigger" do
  action :enable
end

## Nominatim UI

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

## Nominatim QA

if node[:nominatim][:enable_qa_tiles]

  package %w[
    rapidjson-dev
    libmapbox-variant-dev
    libprotozero-dev
  ]

  python_package "nominatim-data-analyser" do
    action :upgrade
    python_virtualenv python_directory
    extra_index_url node[:nominatim][:pip_index]
  end

  directory qa_data_directory do
    owner "nominatim"
    group "nominatim"
    mode "755"
    recursive true
  end

  template "#{project_directory}/qa-config.yaml" do
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
    directory qa_data_directory
    variables :qa_data_directory => qa_data_directory
  end
end

## Logging and monitoring

template "/etc/logrotate.d/nominatim" do
  source "logrotate.nominatim.erb"
  owner "root"
  group "root"
  mode "644"
end

prometheus_exporter "nominatim" do
  port 8082
  user "www-data"
  restrict_address_families "AF_UNIX"
  options [
    "--nominatim.query-log=#{node[:nominatim][:logdir]}/query.log",
    "--nominatim.database-name=#{node[:nominatim][:dbname]}"
  ]
end

frontend_addresses = frontends.collect { |f| f.ipaddresses(:role => :external) }

fail2ban_jail "nominatim_limit_req" do
  filter "nginx-limit-req"
  logpath "#{node[:nominatim][:logdir]}/nominatim.openstreetmap.org-error.log"
  ports [80, 443]
  maxretry 20
  ignoreips frontend_addresses.flatten.sort
end
