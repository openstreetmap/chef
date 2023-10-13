#
# Cookbook:: oxidized
# Recipe:: default
#
# Copyright:: 2022, OpenStreetMap Foundation
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

include_recipe "git"
include_recipe "ruby"

package %w[
  gcc
  g++
  make
  cmake
  libssl-dev
  libssh2-1-dev
  zlib1g-dev
  pkg-config
  libyaml-dev
]

keys = data_bag_item("oxidized", "keys")
devices = data_bag_item("oxidized", "devices")

directory "/etc/oxidized" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/oxidized/config" do
  source "config.erb"
  owner "oxidized"
  group "oxidized"
  mode "444"
  notifies :restart, "service[oxidized]"
end

template "/etc/oxidized/routers.db" do
  source "routers.db.erb"
  owner "oxidized"
  group "oxidized"
  mode "400"
  variables :devices => devices
  notifies :restart, "service[oxidized]"
end

directory "/var/log/oxidized" do
  owner "oxidized"
  group "oxidized"
  mode "755"
end

directory "/opt/oxidized" do
  owner "oxidized"
  group "oxidized"
  mode "755"
end

git "/opt/oxidized/daemon" do
  action :sync
  repository "https://github.com/openstreetmap/oxidized.git"
  depth 1
  user "oxidized"
  group "oxidized"
  notifies :run, "bundle_install[/opt/oxidized/daemon]", :immediately
end

directory "/opt/oxidized/.ssh" do
  owner "oxidized"
  group "oxidized"
  mode "700"
end

# Key is set as a deployment key in github repo
file "/opt/oxidized/.ssh/id_ed25519" do
  content keys["git"].join("\n")
  owner "oxidized"
  group "oxidized"
  mode "400"
  notifies :delete, "file[/opt/oxidized/.ssh/id_ed25519.pub]", :immediately
  notifies :restart, "service[oxidized]"
end

# Ensure public key is deleted if private key is changed. Trigged by notify
file "/opt/oxidized/.ssh/id_ed25519.pub" do
  action :nothing
end

execute "/opt/oxidized/.ssh/id_ed25519.pub" do
  command "ssh-keygen -f /opt/oxidized/.ssh/id_ed25519 -y > /opt/oxidized/.ssh/id_ed25519.pub"
  user "oxidized"
  group "oxidized"
  creates "/opt/oxidized/.ssh/id_ed25519.pub"
  notifies :restart, "service[oxidized]"
end

ssh_known_hosts_entry "github.com" do
  action [:create, :flush]
  file_location "/opt/oxidized/.ssh/known_hosts"
  owner "oxidized"
  group "oxidized"
end

directory "/var/lib/oxidized" do
  owner "oxidized"
  group "oxidized"
  mode "750"
end

git "/var/lib/oxidized/configs.git" do
  action :sync
  repository "git@github.com:openstreetmap/oxidized-configs.git" # Uses oxidized ssh key
  checkout_branch "master" # branch is hardcoded in oxidized
  user "oxidized"
  group "oxidized"
end

bundle_install "/opt/oxidized/daemon" do
  action :nothing
  options "--deployment"
  user "oxidized"
  group "oxidized"
  notifies :restart, "service[oxidized]"
end

# Based on https://github.com/ytti/oxidized/blob/master/extra/oxidized.service
systemd_service "oxidized" do
  description "oxidized network device backup daemon"
  after "network.target"
  user "oxidized"
  working_directory "/opt/oxidized/daemon"
  runtime_directory "oxidized"
  exec_start "#{node[:ruby][:bundle]} exec oxidized"
  environment "OXIDIZED_HOME" => "/etc/oxidized",
              "OXIDIZED_LOGS" => "/var/log/oxidized"
  nice 10
  sandbox :enable_network => true
  read_write_paths ["/run/oxidized", "/var/lib/oxidized", "/var/log/oxidized"]
  restart "on-failure"
  notifies :restart, "service[oxidized]"
end

service "oxidized" do
  action [:enable, :start]
end

template "/etc/logrotate.d/oxidized" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode "644"
end
