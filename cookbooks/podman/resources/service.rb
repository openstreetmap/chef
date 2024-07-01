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
property :volume, Hash, :default => {}

action :create do
  systemd_service new_resource.service do
    description new_resource.description
    type "notify"
    notify_access "all"
    environment "PODMAN_SYSTEMD_UNIT" => "%n"
    exec_start_pre "/bin/rm --force %t/%n.ctr-id"
    exec_start "/usr/bin/podman run --cidfile=%t/%n.ctr-id --cgroups=no-conmon --userns=auto --label=io.containers.autoupdate=registry --pids-limit=-1 #{publish_options} #{environment_options} #{volume_options} --rm --sdnotify=conmon --detach --replace --name=%N #{new_resource.image}"
    exec_stop "/usr/bin/podman stop --ignore --time=10 --cidfile=%t/%n.ctr-id"
    exec_stop_post "/usr/bin/podman rm --force --ignore --cidfile=%t/%n.ctr-id"
    timeout_start_sec 180
    timeout_stop_sec 70
    restart "on-failure"
  end

  # No action :start here to avoid a start and then immediate :restart, due to subscribe, on first run
  # FIXME: Ubuntu 22.04 podman/crun bug workaround "retries"
  service new_resource.service do
    action :enable
    subscribes :restart, "systemd_service[#{new_resource.service}]", :immediately
    retries 4 # Workaround https://github.com/containers/podman/issues/9752
    retry_delay 5
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

  systemd_service new_resource.service do
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
    new_resource.volume.collect do |key, value|
      "-v '#{key}:#{value}'"
    end.join(" ")
  end
end
