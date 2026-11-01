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
  aardvark-dns
  fuse-overlayfs
  passt
  podman
  slirp4netns
  uidmap
]

directory "/var/lib/podman" do
  owner "root"
  group "root"
  mode "0700"
end

%w[subuid subgid].each do |name|
  file "/etc/#{name}" do
    owner "root"
    group "root"
    mode "0644"
    action :create_if_missing
  end

  ruby_block "#{name}-containers" do
    block do
      file = Chef::Util::FileEdit.new("/etc/#{name}")
      file.search_file_delete_line(/^containers:/)
      file.insert_line_if_no_match(/^containers:/, "containers:2147483647:1073741825")
      file.write_file
    end
    not_if "test \"$(grep '^containers:' /etc/#{name})\" = 'containers:2147483647:1073741825'"
  end
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
end

systemd_timer "podman-system-prune" do
  description "Cleanup up unused podman images and containers"
  on_boot_sec "2h"
  on_unit_active_sec "7d"
end

service "podman-system-prune.timer" do
  action [:enable, :start]
end

# Reset graph driver if vfs which is very slow. overlay is the default on Debian 13 and later.
execute "podman-fix-graph-driver" do
  command "podman system reset --force"
  only_if "test $(podman info --format '{{json .Store}}' | jq -r .graphDriverName) = 'vfs'"
  ignore_failure true
end
