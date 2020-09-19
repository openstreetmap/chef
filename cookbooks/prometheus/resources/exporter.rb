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
property :github_owner, :kind_of => String, :default => "prometheus"
property :github_project, :kind_of => String
property :version, :kind_of => String, :required => [:create]
property :port, :kind_of => Integer, :required => [:create]
property :listen_switch, :kind_of => String, :default => "web.listen-address"
property :options, :kind_of => [String, Array]

action :create do
  package "prometheus-#{new_resource.exporter}-exporter" do
    action :purge
  end

  remote_file archive_file do
    action :create_if_missing
    source archive_url
    owner "root"
    group "root"
    mode "644"
    backup false
  end

  execute archive_file do
    action :nothing
    command "tar -xf #{archive_file}"
    cwd "/opt/prometheus"
    user "root"
    group "root"
    subscribes :run, "remote_file[#{archive_file}]"
  end

  systemd_service service_name do
    description "Prometheus #{new_resource.exporter} exporter"
    type "simple"
    user "root"
    exec_start "#{executable_path} #{executable_options}"
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
  def github_project
    new_resource.github_project || "#{new_resource.exporter}_exporter"
  end

  def archive_url
    "https://github.com/#{new_resource.github_owner}/#{github_project}/releases/download/v#{new_resource.version}/#{github_project}-#{new_resource.version}.linux-amd64.tar.gz"
  end

  def archive_file
    "#{Chef::Config[:file_cache_path]}/prometheus-#{new_resource.exporter}-exporter-#{new_resource.version}.tar.gz"
  end

  def service_name
    "prometheus-#{new_resource.exporter}-exporter"
  end

  def executable_path
    "/opt/prometheus/#{github_project}-#{new_resource.version}.linux-amd64/#{github_project}"
  end

  def executable_options
    "--#{new_resource.listen_switch}=#{listen_address} #{Array(new_resource.options).join(' ')}"
  end

  def listen_address
    if node[:prometheus][:mode] == "wireguard"
      "[#{node[:prometheus][:address]}]:#{new_resource.port}"
    else
      "#{node[:prometheus][:address]}:#{new_resource.port}"
    end
  end
end
