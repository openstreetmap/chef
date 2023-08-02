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
property :user, :kind_of => String
property :group, :kind_of => String
property :command, :kind_of => String
property :options, :kind_of => [String, Array]
property :environment, :kind_of => Hash, :default => {}
property :protect_proc, String
property :proc_subset, String
property :capability_bounding_set, [String, Array]
property :ambient_capabilities, [String, Array]
property :private_devices, [true, false]
property :private_users, [true, false]
property :protect_clock, [true, false]
property :restrict_address_families, [String, Array]
property :remove_ipc, [true, false]
property :system_call_filter, [String, Array]
property :service, :kind_of => String
property :labels, :kind_of => Hash, :default => {}
property :scrape_interval, :kind_of => String
property :scrape_timeout, :kind_of => String
property :metric_relabel, :kind_of => Array
property :register_target, :kind_of => [TrueClass, FalseClass], :default => true
property :ssh, [true, false]

action :create do
  if new_resource.ssh && new_resource.user.nil?
    keys = data_bag_item("prometheus", "keys")

    directory "/var/lib/private/prometheus/#{new_resource.exporter}-exporter" do
      mode "700"
      recursive true
    end

    file "/var/lib/private/prometheus/#{new_resource.exporter}-exporter/id_rsa" do
      content keys["ssh"].join("\n")
      mode "400"
    end

    cookbook_file "/var/lib/private/prometheus/#{new_resource.exporter}-exporter/id_rsa.pub" do
      mode "644"
    end
  end

  systemd_service service_name do
    after "network-online.target"
    wants "network-online.target"
    description "Prometheus #{new_resource.exporter} exporter"
    type "simple"
    user new_resource.user
    dynamic_user new_resource.user.nil?
    group new_resource.group
    environment new_resource.environment
    exec_start "#{executable_path} #{new_resource.command} #{executable_options}"
    sandbox :enable_network => true
    state_directory "prometheus/#{new_resource.exporter}-exporter" if new_resource.ssh && new_resource.user.nil?
    protect_proc new_resource.protect_proc if new_resource.property_is_set?(:protect_proc)
    proc_subset new_resource.proc_subset if new_resource.property_is_set?(:proc_subset)
    capability_bounding_set new_resource.capability_bounding_set if new_resource.property_is_set?(:capability_bounding_set)
    ambient_capabilities new_resource.ambient_capabilities if new_resource.property_is_set?(:ambient_capabilities)
    private_devices new_resource.private_devices if new_resource.property_is_set?(:private_devices)
    private_users new_resource.private_users if new_resource.property_is_set?(:private_users)
    protect_clock new_resource.protect_clock if new_resource.property_is_set?(:protect_clock)
    restrict_address_families new_resource.restrict_address_families if new_resource.property_is_set?(:restrict_address_families)
    remove_ipc new_resource.remove_ipc if new_resource.property_is_set?(:remove_ipc)
    system_call_filter new_resource.system_call_filter if new_resource.property_is_set?(:system_call_filter)
  end

  service service_name do
    action [:enable, :start]
    subscribes :restart, "systemd_service[#{service_name}]"
  end

  firewall_rule "accept-prometheus-#{new_resource.exporter}" do
    action :accept
    context :incoming
    protocol :tcp
    source :osm
    dest_ports new_resource.port
    only_if { node[:prometheus][:mode] == "external" }
  end

  node.default[:prometheus][:addresses][new_resource.exporter] = listen_address

  if new_resource.register_target
    node.default[:prometheus][:exporters][new_resource.port] = {
      :name => new_resource.exporter,
      :address => listen_address,
      :labels => new_resource.labels,
      :scrape_interval => new_resource.scrape_interval,
      :scrape_timeout => new_resource.scrape_timeout,
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
    if ::File.exist?("#{executable_directory}/#{executable_name}_#{executable_architecture}")
      "#{executable_directory}/#{executable_name}_#{executable_architecture}"
    else
      "#{executable_directory}/#{executable_name}"
    end
  end

  def executable_directory
    "/opt/prometheus-exporters/exporters/#{new_resource.exporter}"
  end

  def executable_name
    "#{new_resource.exporter}_exporter"
  end

  def executable_architecture
    node[:kernel][:machine]
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
