#
# Cookbook:: prometheus
# Recipe:: default
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

include_recipe "git"
include_recipe "networking"

package "ruby"

if node.internal_ipaddress
  node.default[:prometheus][:mode] = "internal"
  node.default[:prometheus][:address] = node.internal_ipaddress
elsif node[:networking][:wireguard][:enabled]
  node.default[:prometheus][:mode] = "wireguard"
  node.default[:prometheus][:address] = node[:networking][:wireguard][:address]

  search(:node, "roles:prometheus") do |server|
    node.default[:networking][:wireguard][:peers] << {
      :public_key => server[:networking][:wireguard][:public_key],
      :allowed_ips => server[:networking][:wireguard][:address],
      :endpoint => "#{server.name}:51820"
    }
  end
else
  node.default[:prometheus][:mode] = "external"
  node.default[:prometheus][:address] = node.external_ipaddress(:family => :inet)
end

directory "/opt/prometheus" do
  action :delete
  recursive true
end

git "/opt/prometheus-exporters" do
  action :sync
  repository "https://github.com/openstreetmap/prometheus-exporters.git"
  revision "main"
  depth 1
  user "root"
  group "root"
end

directory "/etc/prometheus/collectors" do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

directory "/etc/prometheus/exporters" do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

directory "/var/lib/prometheus/node-exporter" do
  owner "root"
  group "adm"
  mode "775"
  recursive true
end

template "/var/lib/prometheus/node-exporter/chef.prom" do
  source "chef.prom.erb"
  owner "root"
  group "root"
  mode "644"
end

metric_relabel = []

node[:hardware][:hwmon].each do |chip, details|
  next unless details[:ignore]

  sensors = details[:ignore].join("|")

  metric_relabel << {
    :source_labels => "chip,sensor",
    :regex => "#{chip};(#{sensors})",
    :action => "drop"
  }
end

prometheus_exporter "node" do
  port 9100
  options %w[
    --collector.textfile.directory=/var/lib/prometheus/node-exporter
    --collector.interrupts
    --collector.ntp
    --collector.processes
    --collector.systemd
    --collector.tcpstat
  ]
  metric_relabel metric_relabel
end

unless node[:prometheus][:snmp].empty?
  prometheus_exporter "snmp" do
    port 9116
    options "--config.file=/opt/prometheus-exporters/exporters/snmp/snmp.yml"
    register_target false
  end
end

if node[:prometheus][:files].empty?
  prometheus_exporter "filestat" do
    action :delete
  end

  file "/etc/prometheus/filestat.yml" do
    action :delete
  end
else
  template "/etc/prometheus/filestat.yml" do
    source "filestat.yml.erb"
    owner "root"
    group "root"
    mode "644"
  end

  prometheus_exporter "filestat" do
    port 9943
    options "--config.file=/etc/prometheus/filestat.yml"
    subscribes :restart, "template[/etc/prometheus/filestat.yml]"
  end
end
