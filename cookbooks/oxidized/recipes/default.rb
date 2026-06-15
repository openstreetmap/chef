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
  logrotate
  libzstd-dev
]

keys = data_bag_item("oxidized", "keys")
devices = data_bag_item("oxidized", "devices")

group "oxidized" do
  gid 529
  append true
end

user "oxidized" do
  uid 529
  gid 529
  comment "oxidized network backup tool"
  home "/opt/oxidized"
  shell "/usr/sbin/nologin"
  manage_home false
end

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

file "/opt/oxidized/.ssh/known_hosts" do
  owner "oxidized"
  group "oxidized"
  mode "0644"
  content <<~KNOWN_HOSTS
    # Managed by Chef
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
  KNOWN_HOSTS
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
  not_if { kitchen? }
end

bundle_config "/opt/oxidized/daemon" do
  user "oxidized"
  group "oxidized"
  settings "deployment" => "true",
           "build.rugged" => "--with-ssh"
end

bundle_install "/opt/oxidized/daemon" do
  action :nothing
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
  restrict_address_families "AF_NETLINK"
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
