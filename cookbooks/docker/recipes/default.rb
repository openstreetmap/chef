#
# Cookbook:: docker
# Recipe:: default
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

include_recipe "apt::docker"

package %w[
  docker-ce
  docker-ce-cli
  containerd.io
  docker-compose-plugin
]

directory "/etc/docker" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/docker/daemon.json" do
  source "daemon.json.erb"
  owner "root"
  group "root"
  mode "644"
end

service "containerd" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/docker/daemon.json]"
end

service "docker" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/docker/daemon.json]"
end

systemd_service "docker-system-prune" do
  description "Cleanup up unused docker images and containers"
  after ["docker.service"]
  wants ["docker.service"]
  user "root"
  exec_start "/usr/bin/docker system prune --all --force"
  sandbox :enable_network => true
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
end

systemd_timer "docker-system-prune" do
  description "Cleanup up unused docker images and containers"
  on_boot_sec "2h"
  on_unit_active_sec "7d"
  randomized_delay_sec "4h"
end

service "docker-system-prune.timer" do
  action [:enable, :start]
end
