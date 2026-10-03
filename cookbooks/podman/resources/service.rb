#
# Cookbook:: podman
# Resource:: podman_service
#
# Copyright:: 2023, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unified_mode true

default_action :create

property :service, String, :name_property => true
property :description, String, :required => true
property :image, String, :required => true
property :ports, Hash, :default => {}
property :environment, Hash, :default => {}
property :volumes, Hash, :default => {}
property :pids_limit, Integer
property :command, String

action :create do
  systemd_container new_resource.service do
    description new_resource.description
    image new_resource.image
    command new_resource.command
    ports new_resource.ports
    environment new_resource.environment
    volumes new_resource.volumes
    pids_limit new_resource.pids_limit
    timeout_start_sec 180
    restart "on-failure"
  end

  # No action :start here to avoid a start and then immediate :restart, due to subscribe, on first run
  service new_resource.service do
    action :nothing
    subscribes :restart, "systemd_container[#{new_resource.service}]", :immediately
  end

  # Ensure the service is started if not running, replies on status of service resource
  notify_group new_resource.service do
    action :run
    notifies :start, "service[#{new_resource.service}]", :immediately
  end
end

action :delete do
  service new_resource.service do
    action [:disable, :stop]
  end

  systemd_container new_resource.service do
    action :delete
  end
end

action_class do
  def publish_options
    new_resource.ports.collect do |host, guest|
      "--publish=127.0.0.1:#{host}:#{guest}"
    end.join(" ")
  end

  def environment_options
    new_resource.environment.collect do |key, value|
      "-e '#{key}=#{value}'"
    end.join(" ")
  end

  def volume_options
    new_resource.volumes.collect do |key, value|
      "-v '#{key}:#{value}'"
    end.join(" ")
  end
end
