#
# Cookbook:: prometheus
# Resource:: prometheus_collector
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

property :collector, :kind_of => String, :name_property => true
property :interval, :kind_of => [Integer, String], :required => [:create]
property :options, :kind_of => [String, Array]
property :environment, :kind_of => Hash, :default => {}

action :create do
  systemd_service service_name do
    description "Prometheus #{new_resource.collector} collector"
    user "root"
    environment new_resource.environment
    standard_output "file:/var/lib/prometheus/node-exporter/#{new_resource.collector}.new"
    standard_error "journal"
    exec_start "#{executable_path} #{executable_options}"
    exec_start_post "/bin/mv /var/lib/prometheus/node-exporter/#{new_resource.collector}.new /var/lib/prometheus/node-exporter/#{new_resource.collector}.prom"
    private_tmp true
    protect_system "strict"
    protect_home true
    read_write_paths "/var/lib/prometheus/node-exporter"
    no_new_privileges true
  end

  systemd_timer service_name do
    description "Prometheus #{new_resource.collector} collector"
    on_boot_sec 60
    on_unit_active_sec new_resource.interval
  end

  service "#{service_name}.timer" do
    action [:enable, :start]
    subscribes :restart, "systemd_timer[#{service_name}]"
  end
end

action :delete do
  service "#{service_name}.timer" do
    action [:disable, :stop]
  end

  systemd_timer service_name do
    action :delete
  end

  systemd_service service_name do
    action :delete
  end
end

action_class do
  def service_name
    "prometheus-#{new_resource.collector}-collector"
  end

  def executable_path
    "/opt/prometheus/collectors/#{new_resource.collector}/#{new_resource.collector}_collector"
  end

  def executable_options
    Array(new_resource.options).join(" ")
  end
end
