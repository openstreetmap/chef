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

unified_mode true

default_action :create

property :collector, :kind_of => String, :name_property => true
property :interval, :kind_of => [Integer, String], :required => [:create]
property :user, :kind_of => String
property :path, :kind_of => String
property :options, :kind_of => [String, Array]
property :environment, :kind_of => Hash, :default => {}
property :proc_subset, String
property :capability_bounding_set, [String, Array]
property :private_devices, [true, false]
property :private_users, [true, false]
property :protect_clock, [true, false]
property :protect_kernel_modules, [true, false]

action :create do
  systemd_service service_name do
    description "Prometheus #{new_resource.collector} collector"
    type "oneshot"
    user new_resource.user
    dynamic_user new_resource.user.nil?
    group "adm"
    environment new_resource.environment
    standard_output "file:/var/lib/prometheus/node-exporter/#{new_resource.collector}.new"
    standard_error "journal"
    exec_start "#{executable_path} #{executable_options}"
    exec_start_post "/bin/mv /var/lib/prometheus/node-exporter/#{new_resource.collector}.new /var/lib/prometheus/node-exporter/#{new_resource.collector}.prom"
    sandbox true
    proc_subset new_resource.proc_subset if new_resource.property_is_set?(:proc_subset)
    capability_bounding_set new_resource.capability_bounding_set if new_resource.property_is_set?(:capability_bounding_set)
    private_devices new_resource.private_devices if new_resource.property_is_set?(:private_devices)
    private_users new_resource.private_users if new_resource.property_is_set?(:private_users)
    protect_clock new_resource.protect_clock if new_resource.property_is_set?(:protect_clock)
    protect_kernel_modules new_resource.protect_kernel_modules if new_resource.property_is_set?(:protect_kernel_modules)
    read_write_paths ["/var/lib/prometheus/node-exporter", "/var/lock", "/var/log"]
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

  file "/var/lib/prometheus/node-exporter/#{new_resource.collector}.prom" do
    action :delete
  end
end

action_class do
  def service_name
    "prometheus-#{new_resource.collector}-collector"
  end

  def executable_path
    new_resource.path || "/opt/prometheus-exporters/collectors/#{new_resource.collector}/#{new_resource.collector}_collector"
  end

  def executable_options
    Array(new_resource.options).join(" ")
  end
end
