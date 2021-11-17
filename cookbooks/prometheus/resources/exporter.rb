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

unified_mode true

default_action :create

property :exporter, :kind_of => String, :name_property => true
property :address, :kind_of => String
property :port, :kind_of => Integer, :required => [:create]
property :listen_switch, :kind_of => String, :default => "web.listen-address"
property :listen_type, :kind_of => String, :default => "address"
property :user, :kind_of => String, :default => "root"
property :command, :kind_of => String
property :options, :kind_of => [String, Array]
property :environment, :kind_of => Hash, :default => {}
property :service, :kind_of => String
property :metric_relabel, :kind_of => Array
property :register_target, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  systemd_service service_name do
    description "Prometheus #{new_resource.exporter} exporter"
    type "simple"
    user new_resource.user
    environment new_resource.environment
    exec_start "#{executable_path} #{new_resource.command} #{executable_options}"
    private_tmp true
    protect_system "strict"
    protect_home true
    no_new_privileges true
  end

  service service_name do
    action [:enable, :start]
    subscribes :restart, "systemd_service[#{service_name}]"
  end

  firewall_rule "accept-prometheus-#{new_resource.exporter}" do
    action :accept
    source "osm"
    dest "fw"
    proto "tcp:syn"
    dest_ports new_resource.port
    only_if { node[:prometheus][:mode] == "external" }
  end

  node.default[:prometheus][:addresses][new_resource.exporter] = listen_address

  if new_resource.register_target
    node.default[:prometheus][:exporters][new_resource.port] = {
      :name => new_resource.exporter,
      :address => listen_address,
      :metric_relabel => new_resource.metric_relabel
    }
  end
end

action :delete do
  service service_name do
    action [:disable, :stop]
  end

  systemd_service service_name do
    action :delete
  end
end

action :restart do
  service service_name do
    action :restart
    only_if { service_exists? }
  end
end

action_class do
  def service_name
    if new_resource.service
      "prometheus-#{new_resource.service}-exporter"
    else
      "prometheus-#{new_resource.exporter}-exporter"
    end
  end

  def service_exists?
    ::File.exist?("/etc/systemd/system/#{service_name}.service")
  end

  def executable_path
    "/opt/prometheus-exporters/exporters/#{new_resource.exporter}/#{new_resource.exporter}_exporter"
  end

  def executable_options
    "--#{new_resource.listen_switch}=#{listen_argument} #{Array(new_resource.options).join(' ')}"
  end

  def listen_argument
    case new_resource.listen_type
    when "address" then listen_address
    when "url" then "http://#{listen_address}/metrics"
    end
  end

  def listen_address
    if new_resource.address
      "#{new_resource.address}:#{new_resource.port}"
    elsif node[:prometheus][:mode] == "wireguard"
      "[#{node[:prometheus][:address]}]:#{new_resource.port}"
    else
      "#{node[:prometheus][:address]}:#{new_resource.port}"
    end
  end
end

def after_created
  subscribes :restart, "git[/opt/prometheus-exporters]"
end
