#
# Cookbook:: systemd
# Resource:: systemd_container
#
# Copyright:: 2026, OpenStreetMap Foundation
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

property :container, String, :name_property => true
property :description, String
property :image, String
property :command, String
property :ports, Hash, :default => {}
property :environment, Hash, :default => {}
property :volumes, Hash, :default => {}
property :pids_limit, Integer
property :timeout_start_sec, Integer
property :restart, String,
         :is => %w[on-success on-failure on-abnormal on-watchdog on-abort always]

action :create do
  container_variables = new_resource.to_hash

  template config_name do
    cookbook "systemd"
    source "container.erb"
    owner "root"
    group "root"
    mode "644"
    variables container_variables
  end

  execute "systemctl-reload" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "template[#{config_name}]"
  end
end

action :delete do
  file config_name do
    action :delete
  end

  execute "systemctl-reload" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "file[#{config_name}]"
  end
end

action_class do
  def config_name
    "/etc/containers/systemd/#{new_resource.container}.container"
  end
end
