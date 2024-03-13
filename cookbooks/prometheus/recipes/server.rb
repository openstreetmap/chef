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
include_recipe "apt::grafana"
include_recipe "awscli"
include_recipe "networking"

passwords = data_bag_item("prometheus", "passwords")
tokens = data_bag_item("prometheus", "tokens")
admins = data_bag_item("apache", "admins")

prometheus_exporter "fastly" do
  port 8080
  listen_switch "listen"
  environment "FASTLY_API_TOKEN" => tokens["fastly"]
end

prometheus_exporter "fastly_healthcheck" do
  port 9696
  scrape_interval "1m"
  environment "FASTLY_API_TOKEN" => tokens["fastly"]
end

prometheus_exporter "statuscake" do
  port 9595
  scrape_interval "5m"
  scrape_timeout "2m"
  environment "STATUSCAKE_APIKEY" => tokens["statuscake"]
end

template "/etc/prometheus/cloudwatch.yml" do
  source "cloudwatch.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

prometheus_exporter "cloudwatch" do
  address "127.0.0.1"
  port 5000
  listen_switch "listen-address"
  options %w[
    --config.file=/etc/prometheus/cloudwatch.yml
    --enable-feature=aws-sdk-v2
    --enable-feature=always-return-info-metrics
  ]
  environment "AWS_ACCESS_KEY_ID" => "AKIASQUXHPE7JHG37EA6",
              "AWS_SECRET_ACCESS_KEY" => tokens["cloudwatch"]
  subscribes :restart, "template[/etc/prometheus/cloudwatch.yml]"
end

cache_dir = Chef::Config[:file_cache_path]

prometheus_version = "2.45.0"
alertmanager_version = "0.25.0"
karma_version = "0.114"

directory "/opt/prometheus-server" do
  owner "root"
  group "root"
  mode "755"
end

prometheus_arch = if arm?
                    "arm64"
                  else
                    "amd64"
                  end

remote_file "#{cache_dir}/prometheus.linux.tar.gz" do
  source "https://github.com/prometheus/prometheus/releases/download/v#{prometheus_version}/prometheus-#{prometheus_version}.linux-#{prometheus_arch}.tar.gz"
  owner "root"
  group "root"
  mode "644"
  backup false
end

archive_file "#{cache_dir}/prometheus.linux.tar.gz" do
  action :nothing
  destination "/opt/prometheus-server/prometheus"
  overwrite true
  strip_components 1
  owner "root"
  group "root"
  subscribes :extract, "remote_file[#{cache_dir}/prometheus.linux.tar.gz]", :immediately
end

remote_file "#{cache_dir}/alertmanager.linux.tar.gz" do
  source "https://github.com/prometheus/alertmanager/releases/download/v#{alertmanager_version}/alertmanager-#{alertmanager_version}.linux-#{prometheus_arch}.tar.gz"
  owner "root"
  group "root"
  mode "644"
  backup false
end

archive_file "#{cache_dir}/alertmanager.linux.tar.gz" do
  action :nothing
  destination "/opt/prometheus-server/alertmanager"
  overwrite true
  strip_components 1
  owner "root"
  group "root"
  subscribes :extract, "remote_file[#{cache_dir}/alertmanager.linux.tar.gz]", :immediately
end

remote_file "#{cache_dir}/karma-linux.tar.gz" do
  source "https://github.com/prymitive/karma/releases/download/v#{karma_version}/karma-linux-#{prometheus_arch}.tar.gz"
  owner "root"
  group "root"
  mode "644"
  backup false
end

archive_file "#{cache_dir}/karma-linux.tar.gz" do
  action :nothing
  destination "/opt/prometheus-server/karma"
  overwrite true
  owner "root"
  group "root"
  subscribes :extract, "remote_file[#{cache_dir}/karma-linux.tar.gz]", :immediately
end

search(:node, "roles:gateway") do |gateway|
  allowed_ips = gateway.ipaddresses(:role => :internal).map(&:subnet)

  node.default[:networking][:wireguard][:peers] << {
    :public_key => gateway[:networking][:wireguard][:public_key],
    :allowed_ips => allowed_ips,
    :endpoint => "#{gateway.name}:51820"
  }
end

jobs = {}
junos_targets = []
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
      labels = Array(exporter[:labels])
      scrape_interval = exporter[:scrape_interval]
      scrape_timeout = exporter[:scrape_timeout]
      metric_relabel = exporter[:metric_relabel] || []
    else
      name = key
      address = exporter
      sni = nil
      labels = []
      scrape_interval = nil
      scrape_timeout = nil
      metric_relabel = []
    end

    jobs[name] ||= []
    jobs[name] << {
      :address => address,
      :sni => sni,
      :instance => client.name.split(".").first,
      :labels => labels,
      :scrape_interval => scrape_interval,
      :scrape_timeout => scrape_timeout,
      :metric_relabel => metric_relabel
    }
  end

  Hash(client[:prometheus][:junos]).each do |instance, details|
    junos_targets << {
      :instance => instance,
      :target => details[:address],
      :address => client[:prometheus][:addresses]["junos"],
      :labels => Array(details[:labels])
    }
  end

  Hash(client[:prometheus][:snmp]).each do |instance, details|
    snmp_targets << {
      :instance => instance,
      :target => details[:address],
      :modules => details[:modules],
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

package "prometheus"

systemd_service "prometheus-executable" do
  service "prometheus"
  dropin "executable"
  exec_start "/opt/prometheus-server/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --web.enable-admin-api --web.external-url=https://prometheus.openstreetmap.org/prometheus --storage.tsdb.path=/var/lib/prometheus/metrics2 --storage.tsdb.retention.time=540d"
  timeout_stop_sec 300
  notifies :restart, "service[prometheus]"
end

template "/etc/prometheus/prometheus.yml" do
  source "prometheus.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :jobs => jobs, :junos_targets => junos_targets, :snmp_targets => snmp_targets, :certificates => certificates
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
  subscribes :restart, "archive_file[#{cache_dir}/prometheus.linux.tar.gz]"
end

systemd_service "prometheus-alertmanager" do
  description "Prometheus alert manager"
  type "simple"
  user "prometheus"
  exec_start "/opt/prometheus-server/alertmanager/alertmanager --config.file=/etc/prometheus/alertmanager.yml --storage.path=/var/lib/prometheus/alertmanager --web.external-url=https://prometheus.openstreetmap.org/alertmanager"
  exec_reload "/bin/kill -HUP $MAINPID"
  timeout_stop_sec 20
  restart "on-failure"
  notifies :restart, "service[prometheus-alertmanager]"
end

link "/usr/local/bin/promtool" do
  to "/opt/prometheus-server/prometheus/promtool"
end

template "/etc/prometheus/alertmanager.yml" do
  source "alertmanager.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/var/lib/prometheus/alertmanager" do
  owner "prometheus"
  group "prometheus"
  mode "755"
end

service "prometheus-alertmanager" do
  action [:enable, :start]
  subscribes :reload, "template[/etc/prometheus/alertmanager.yml]"
  subscribes :restart, "systemd_service[prometheus-alertmanager]"
  subscribes :restart, "archive_file[#{cache_dir}/alertmanager.linux.tar.gz]"
end

directory "/etc/amtool" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/amtool/config.yml" do
  source "amtool.yml.erb"
  owner "root"
  group "root"
  mode "644"
end

link "/usr/local/bin/amtool" do
  to "/opt/prometheus-server/alertmanager/amtool"
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
  exec_start "/opt/prometheus-server/karma/karma-linux-#{prometheus_arch} --config.file=/etc/prometheus/karma.yml"
  sandbox :enable_network => true
  restart "on-failure"
end

service "prometheus-karma" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/prometheus/karma.yml]"
  subscribes :restart, "archive_file[#{cache_dir}/karma-linux.tar.gz]"
  subscribes :restart, "systemd_service[prometheus-karma]"
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
apache_module "proxy_wstunnel"

ssl_certificate "prometheus.openstreetmap.org" do
  domains ["prometheus.openstreetmap.org", "prometheus.osm.org", "munin.openstreetmap.org", "munin.osm.org"]
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

package %w[
  curl
  jq
]

directory "/var/lib/prometheus/.aws" do
  user "prometheus"
  group "prometheus"
  mode "755"
end

template "/var/lib/prometheus/.aws/credentials" do
  source "aws-credentials.erb"
  user "prometheus"
  group "prometheus"
  mode "600"
  variables :passwords => passwords
end

template "/usr/local/bin/prometheus-backup-data" do
  source "backup-data.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "prometheus-backup-data" do
  description "Backup prometheus data to S3"
  user "prometheus"
  exec_start "/usr/local/bin/prometheus-backup-data"
  read_write_paths %w[
    /var/lib/prometheus/.aws
    /var/lib/prometheus/metrics2/snapshots
  ]
  sandbox :enable_network => true
end

systemd_timer "prometheus-backup-data" do
  description "Backup prometheus data to S3"
  on_calendar "03:11"
end

service "prometheus-backup-data.timer" do
  action [:enable, :start]
end
