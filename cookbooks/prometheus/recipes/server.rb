#
# Cookbook:: prometheus
# Recipe:: server
#
# Copyright:: 2020, OpenStreetMap Foundation
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
include_recipe "apt"
include_recipe "networking"
include_recipe "timescaledb"

passwords = data_bag_item("prometheus", "passwords")
tokens = data_bag_item("prometheus", "tokens")

prometheus_exporter "fastly" do
  port 8080
  listen_switch "endpoint"
  listen_type "url"
  environment "FASTLY_API_TOKEN" => tokens["fastly"]
end

package %w[
  prometheus
  prometheus-alertmanager
]

promscale_version = "0.1.4"

database_cluster = node[:timescaledb][:cluster]

postgresql_user "prometheus" do
  cluster database_cluster
  createrole true
end

postgresql_database "promscale" do
  cluster database_cluster
  owner "prometheus"
end

postgresql_extension "timescaledb" do
  cluster database_cluster
  database "promscale"
end

directory "/opt/promscale" do
  owner "root"
  group "root"
  mode "755"
end

package %w[
  make
  gcc
  clang-9
  llvm-9
  cargo
]

git "/opt/promscale/extension" do
  action :sync
  repository "https://github.com/timescale/promscale_extension.git"
  revision "0.1.1"
  user "root"
  group "root"
end

execute "/opt/promscale/extension/Makefile" do
  action :nothing
  command "make install"
  cwd "/opt/promscale/extension"
  user "root"
  group "root"
  subscribes :run, "git[/opt/promscale/extension]", :immediately
  notifies :restart, "service[postgresql]", :immediately
end

directory "/opt/promscale/bin" do
  owner "root"
  group "root"
  mode "755"
end

remote_file "/opt/promscale/bin/promscale" do
  action :create
  source "https://github.com/timescale/promscale/releases/download/#{promscale_version}/promscale_#{promscale_version}_Linux_x86_64"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "promscale" do
  description "Promscale Connector"
  type "simple"
  user "prometheus"
  exec_start "/opt/promscale/bin/promscale --db-host /run/postgresql --db-port 5432 --db-user prometheus --db-name promscale --db-connections-max 400"
  # exec_start lazy { "/opt/promscale/bin/promscale --db-host /run/postgresql --db-port #{node[:postgresql][:clusters][database_cluster][:port]} --db-user prometheus --db-name promscale --db-max-connections 400" }
  limit_nofile 16384
  private_tmp true
  protect_system "strict"
  protect_home true
  no_new_privileges true
end

service "promscale" do
  action [:enable, :start]
  subscribes :restart, "remote_file[/opt/promscale/bin/promscale]"
  subscribes :restart, "systemd_service[promscale]"
end

postgresql_extension "promscale" do
  cluster database_cluster
  database "promscale"
  notifies :restart, "service[promscale]"
end

systemd_service "promscale-maintenance" do
  description "Promscale Maintenace"
  type "simple"
  user "prometheus"
  exec_start "/usr/bin/psql --command='CALL prom_api.execute_maintenance()' promscale"
  private_tmp true
  protect_system "strict"
  protect_home true
  no_new_privileges true
end

systemd_timer "promscale-maintenance" do
  description "Promscale Maintenace"
  on_active_sec 1800
  on_unit_inactive_sec 1800
end

jobs = {}

search(:node, "recipes:prometheus\\:\\:default").sort_by(&:name).each do |client|
  if client[:prometheus][:mode] == "wireguard"
    node.default[:networking][:wireguard][:peers] << {
      :public_key => client[:networking][:wireguard][:public_key],
      :allowed_ips => client[:networking][:wireguard][:address],
      :endpoint => "#{client.name}:51820"
    }
  end

  client[:prometheus][:exporters].each do |key, exporter|
    if exporter.is_a?(Hash)
      name = exporter[:name]
      address = exporter[:address]
    else
      name = key
      address = exporter
    end

    jobs[name] ||= []
    jobs[name] << { :address => address, :name => client.name }
  end
end

template "/etc/prometheus/prometheus.yml" do
  source "prometheus.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :jobs => jobs
end

service "prometheus" do
  action [:enable, :start]
  subscribes :reload, "template[/etc/prometheus/prometheus.yml]"
end

template "/etc/prometheus/alertmanager.yml" do
  source "alertmanager.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

service "prometheus-alertmanager" do
  action [:enable, :start]
  subscribes :reload, "template[/etc/prometheus/alertmanager.yml]"
end

package "grafana-enterprise"

template "/etc/grafana/grafana.ini" do
  source "grafana.ini.erb"
  owner "root"
  group "grafana"
  mode "640"
  variables :passwords => passwords
end

service "grafana-server" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/grafana/grafana.ini]"
end

apache_module "alias"
apache_module "proxy_http"

ssl_certificate "prometheus.openstreetmap.org" do
  domains ["prometheus.openstreetmap.org", "prometheus.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "prometheus.openstreetmap.org" do
  template "apache.erb"
end
