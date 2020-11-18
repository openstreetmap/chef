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

passwords = data_bag_item("prometheus", "passwords")
tokens = data_bag_item("prometheus", "tokens")

prometheus_exporter "fastly" do
  port 8080
  listen_switch "endpoint"
  listen_type "url"
  environment "FASTLY_API_TOKEN" => tokens["fastly"]
end

package "prometheus"

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
