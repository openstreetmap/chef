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

passwords = data_bag_item("prometheus", "passwords")

package "prometheus"

clients = search(:node, "recipes:prometheus\\:\\:default").sort_by(&:name)

prometheus_jobs = clients.each_with_object({}) do |client, jobs|
  client[:prometheus][:exporters].each do |name, address|
    jobs[name] ||= []
    jobs[name] << address
  end
end

template "/etc/prometheus/prometheus.yml" do
  source "prometheus.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :jobs => prometheus_jobs
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
