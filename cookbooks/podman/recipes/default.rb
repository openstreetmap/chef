#
# Cookbook:: podman
# Recipe:: default
#
# Copyright:: 2023, OpenStreetMap Foundation
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

package %w[
  podman
  slirp4netns
  uidmap
  fuse-overlayfs
]

ruby_block "subuid-containers" do
  block do
    File.open("/etc/subuid", "a") do |file|
      file.puts("containers:2147483647:2147483648")
    end
  end
  not_if "grep -q '^containers:' /etc/subuid"
end

ruby_block "subgid-containers" do
  block do
    File.open("/etc/subgid", "a") do |file|
      file.puts("containers:2147483647:2147483648")
    end
  end
  not_if "grep -q '^containers:' /etc/subgid"
end

systemd_timer "podman-auto-update-frequency" do
  timer "podman-auto-update"
  dropin "frequency"
  on_boot_sec "5m"
  on_unit_inactive_sec "20m"
  randomized_delay_sec "5m"
end

service "podman-auto-update.timer" do
  action [:enable, :start]
end

systemd_service "podman-system-prune" do
  description "Cleanup up unused podman images and containers"
  exec_start "/usr/bin/podman system prune --all --force"
  sandbox :enable_network => true
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
  read_write_paths "/var/lib/containers"
end

systemd_timer "podman-system-prune" do
  description "Cleanup up unused podman images and containers"
  on_boot_sec "2h"
  on_unit_active_sec "7d"
end

service "podman-system-prune.timer" do
  action [:enable, :start]
end
