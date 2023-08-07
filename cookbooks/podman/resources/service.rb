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
property :ports, Hash

action :create do
  systemd_service new_resource.service do
    description new_resource.description
    type "notify"
    notify_access "all"
    environment "PODMAN_SYSTEMD_UNIT" => "%n"
    # The exec_start_pre "podman pull" is to workaround the occasional 502 error returned from the registry.
    exec_start_pre [
      "/bin/rm --force %t/%n.ctr-id",
      "-/usr/bin/podman pull #{new_resource.image}"
    ]
    exec_start "/usr/bin/podman run --cidfile=%t/%n.ctr-id --cgroups=no-conmon --userns=auto --label=io.containers.autoupdate=registry --network=slirp4netns:mtu=1500 #{publish_options} --rm --sdnotify=conmon --detach --replace --name=%N #{new_resource.image}"
    exec_stop "/usr/bin/podman stop --ignore --time=10 --cidfile=%t/%n.ctr-id"
    exec_stop_post "/usr/bin/podman rm --force --ignore --cidfile=%t/%n.ctr-id"
    timeout_start_sec 180
    timeout_stop_sec 70
    restart "on-failure"
  end

  service new_resource.service do
    action [:enable, :start]
    subscribes :restart, "systemd_service[#{new_resource.service}]"
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
end
