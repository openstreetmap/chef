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
admins = data_bag_item("apache", "admins")

prometheus_exporter "fastly" do
  port 8080
  listen_switch "listen"
  environment "FASTLY_API_TOKEN" => tokens["fastly"]
end

cache_dir = Chef::Config[:file_cache_path]

prometheus_version = "2.31.1"
alertmanager_version = "0.23.0"
karma_version = "0.93"

directory "/opt/prometheus-server" do
  owner "root"
  group "root"
  mode "755"
end

remote_file "#{cache_dir}/prometheus.linux-amd64.tar.gz" do
  source "https://github.com/prometheus/prometheus/releases/download/v#{prometheus_version}/prometheus-#{prometheus_version}.linux-amd64.tar.gz"
  owner "root"
  group "root"
  mode "644"
  backup false
end

archive_file "#{cache_dir}/prometheus.linux-amd64.tar.gz" do
  action :nothing
  destination "/opt/prometheus-server/prometheus"
  overwrite true
  strip_components 1
  owner "root"
  group "root"
  subscribes :extract, "remote_file[#{cache_dir}/prometheus.linux-amd64.tar.gz]"
end

remote_file "#{cache_dir}/alertmanager.linux-amd64.tar.gz" do
  source "https://github.com/prometheus/alertmanager/releases/download/v#{alertmanager_version}/alertmanager-#{alertmanager_version}.linux-amd64.tar.gz"
  owner "root"
  group "root"
  mode "644"
  backup false
end

archive_file "#{cache_dir}/alertmanager.linux-amd64.tar.gz" do
  action :nothing
  destination "/opt/prometheus-server/alertmanager"
  overwrite true
  strip_components 1
  owner "root"
  group "root"
  subscribes :extract, "remote_file[#{cache_dir}/alertmanager.linux-amd64.tar.gz]"
end

remote_file "#{cache_dir}/karma-linux-amd64.tar.gz" do
  source "https://github.com/prymitive/karma/releases/download/v#{karma_version}/karma-linux-amd64.tar.gz"
  owner "root"
  group "root"
  mode "644"
  backup false
end

archive_file "#{cache_dir}/karma-linux-amd64.tar.gz" do
  action :nothing
  destination "/opt/prometheus-server/karma"
  overwrite true
  owner "root"
  group "root"
  subscribes :extract, "remote_file[#{cache_dir}/karma-linux-amd64.tar.gz]"
end

promscale_version = "0.11.0"

database_version = node[:timescaledb][:database_version]
database_cluster = "#{database_version}/main"

package %W[
  prometheus
  prometheus-alertmanager
  promscale-extension-postgresql-#{database_version}
]

postgresql_user "prometheus" do
  cluster database_cluster
  superuser true
end

postgresql_database "promscale" do
  cluster database_cluster
  owner "prometheus"
end

directory "/opt/promscale" do
  owner "root"
  group "root"
  mode "755"
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
  exec_start "/opt/promscale/bin/promscale --db.uri postgresql:///promscale?host=/run/postgresql&port=5432 --db.connections-max 400"
  limit_nofile 16384
  private_tmp true
  protect_system "strict"
  protect_home true
  no_new_privileges true
end

if node[:prometheus][:promscale]
  service "promscale" do
    action [:enable, :start]
    subscribes :restart, "remote_file[/opt/promscale/bin/promscale]"
    subscribes :restart, "systemd_service[promscale]"
  end
else
  service "promscale" do
    action [:disable, :stop]
  end
end

search(:node, "roles:gateway") do |gateway|
  allowed_ips = gateway.interfaces(:role => :internal).map do |interface|
    "#{interface[:network]}/#{interface[:prefix]}"
  end

  node.default[:networking][:wireguard][:peers] << {
    :public_key => gateway[:networking][:wireguard][:public_key],
    :allowed_ips => allowed_ips,
    :endpoint => "#{gateway.name}:51820"
  }
end

jobs = {}
snmp_targets = []

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
      sni = exporter[:sni]
      metric_relabel = exporter[:metric_relabel] || []
    else
      name = key
      address = exporter
      sni = nil
      metric_relabel = []
    end

    jobs[name] ||= []
    jobs[name] << {
      :address => address,
      :sni => sni,
      :instance => client.name.split(".").first,
      :metric_relabel => metric_relabel
    }
  end

  Hash(client[:prometheus][:snmp]).each do |instance, details|
    snmp_targets << {
      :instance => instance,
      :target => details[:address],
      :module => details[:module],
      :address => client[:prometheus][:addresses]["snmp"],
      :labels => Array(details[:labels])
    }
  end
end

certificates = search(:node, "letsencrypt:certificates").each_with_object({}) do |n, c|
  n[:letsencrypt][:certificates].each do |name, details|
    c[name] ||= details.merge(:nodes => [])

    c[name][:nodes] << {
      :name => n[:fqdn],
      :address => n.external_ipaddress || n.internal_ipaddress
    }
  end
end

template "/etc/prometheus/ssl.yml" do
  source "ssl.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :certificates => certificates
end

prometheus_exporter "ssl" do
  address "127.0.0.1"
  port 9219
  options "--config.file=/etc/prometheus/ssl.yml"
  register_target false
end

systemd_service "prometheus-executable" do
  service "prometheus"
  dropin "executable"
  exec_start "/opt/prometheus-server/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --web.external-url=https://prometheus.openstreetmap.org/prometheus --storage.tsdb.path=/var/lib/prometheus/metrics2"
  notifies :restart, "service[prometheus]"
end

template "/etc/prometheus/prometheus.yml" do
  source "prometheus.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :jobs => jobs, :snmp_targets => snmp_targets, :certificates => certificates
end

template "/etc/prometheus/alert_rules.yml" do
  source "alert_rules.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

service "prometheus" do
  action [:enable, :start]
  subscribes :reload, "template[/etc/prometheus/prometheus.yml]"
  subscribes :reload, "template[/etc/prometheus/alert_rules.yml]"
  subscribes :restart, "archive_file[#{cache_dir}/prometheus.linux-amd64.tar.gz]"
end

systemd_service "prometheus-alertmanager-executable" do
  service "prometheus-alertmanager"
  dropin "executable"
  exec_start "/opt/prometheus-server/alertmanager/alertmanager --config.file=/etc/prometheus/alertmanager.yml --storage.path=/var/lib/prometheus/alertmanager --web.external-url=https://prometheus.openstreetmap.org/alertmanager"
  notifies :restart, "service[prometheus-alertmanager]"
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
  subscribes :restart, "archive_file[#{cache_dir}/alertmanager.linux-amd64.tar.gz]"
end

template "/etc/prometheus/amtool.yml" do
  source "amtool.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

template "/etc/prometheus/karma.yml" do
  source "karma.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

systemd_service "prometheus-karma" do
  description "Alert dashboard for Prometheus Alertmanager"
  user "prometheus"
  exec_start "/opt/prometheus-server/karma/karma-linux-amd64 --config.file=/etc/prometheus/karma.yml"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  no_new_privileges true
  restart "on-failure"
end

service "prometheus-karma" do
  action [:enable, :start]
  subscribes :reload, "template[/etc/prometheus/karma.yml]"
  subscribes :restart, "archive_file[#{cache_dir}/karma-linux-amd64.tar.gz]"
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
  variables :admin_hosts => admins["hosts"]
end

template "/etc/cron.daily/prometheus-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "750"
end
