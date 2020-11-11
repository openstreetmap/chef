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
  owner "root"
  group "root"
  mode "755"
  recursive true
  not_if { ::Dir.exist?("/opt/prometheus/.git") }
end

git "/opt/prometheus" do
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
end
