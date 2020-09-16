#
# Cookbook:: prometheus
# Resource:: prometheus_exporter
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

default_action :create

property :exporter, :kind_of => String, :name_property => true
property :port, :kind_of => Integer, :required => [:create]
property :listen_switch, :kind_of => String, :default => "web.listen-address"
property :package, :kind_of => String
property :package_options, :kind_of => String
property :defaults, :kind_of => String
property :service, :kind_of => String

action :create do
  package package_name do
    options new_resource.package_options
  end

  template defaults_name do
    source "defaults.erb"
    owner "root"
    group "root"
    mode "644"
    variables new_resource.to_hash.merge(:listen_address => listen_address)
  end

  service service_name do
    action [:enable, :start]
    subscribes :restart, "template[#{defaults_name}]"
  end

  firewall_rule "accept-prometheus-#{new_resource.name}" do
    action :accept
    source "osm"
    dest "fw"
    proto "tcp:syn"
    dest_ports new_resource.port
    only_if { node[:prometheus][:mode] == "external" }
  end

  node.default[:prometheus][:exporters][new_resource.exporter] = listen_address
end

action :delete do
  service service_name do
    action [:disable, :stop]
  end

  package package_name do
    action :purge
  end
end

action_class do
  def package_name
    new_resource.package || "prometheus-#{new_resource.exporter}-exporter"
  end

  def defaults_name
    new_resource.defaults || "/etc/default/prometheus-#{new_resource.exporter}-exporter"
  end

  def listen_address
    "#{node[:prometheus][:address]}:#{new_resource.port}"
  end

  def service_name
    new_resource.service || "prometheus-#{new_resource.exporter}-exporter"
  end
end
