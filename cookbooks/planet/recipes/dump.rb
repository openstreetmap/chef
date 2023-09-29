#
# Cookbook:: planet
# Recipe:: dump
#
# Copyright:: 2013, OpenStreetMap Foundation
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

include_recipe "accounts"
include_recipe "git"

package %w[
  gcc
  g++
  make
  autoconf
  automake
  pkg-config
  libxml2-dev
  libboost-dev
  libboost-program-options-dev
  libboost-date-time-dev
  libboost-filesystem-dev
  libboost-thread-dev
  libboost-iostreams-dev
  libosmpbf-dev
  libprotobuf-dev
  osmpbf-bin
  pbzip2
  mktorrent
  xmlstarlet
  libxml2-utils
  inotify-tools
]

directory "/opt/planet-dump-ng" do
  owner "root"
  group "root"
  mode "755"
end

git "/opt/planet-dump-ng" do
  action :sync
  repository "https://github.com/zerebubuth/planet-dump-ng.git"
  revision "v1.2.7"
  depth 1
  user "root"
  group "root"
end

execute "/opt/planet-dump-ng/autogen.sh" do
  action :nothing
  command "./autogen.sh"
  cwd "/opt/planet-dump-ng"
  user "root"
  group "root"
  subscribes :run, "git[/opt/planet-dump-ng]"
end

execute "/opt/planet-dump-ng/configure" do
  action :nothing
  command "./configure"
  cwd "/opt/planet-dump-ng"
  user "root"
  group "root"
  subscribes :run, "execute[/opt/planet-dump-ng/autogen.sh]"
end

execute "/opt/planet-dump-ng/Makefile" do
  action :nothing
  command "make"
  cwd "/opt/planet-dump-ng"
  user "root"
  group "root"
  subscribes :run, "execute[/opt/planet-dump-ng/configure]"
end

directory "/store/planetdump" do
  owner "planet"
  group "planet"
  mode "755"
  recursive true
end

%w[planetdump planetdump-trigger].each do |program|
  template "/usr/local/bin/#{program}" do
    source "#{program}.erb"
    owner "root"
    group "root"
    mode "755"
  end
end

systemd_service "planetdump@" do
  description "Planet dump for %i"
  user "planet"
  exec_start "/usr/local/bin/planetdump %i"
  memory_max "64G"
  sandbox :enable_network => true
  protect_home "tmpfs"
  bind_paths "/home/planet"
  read_write_paths [
    "/store/planetdump",
    "/store/planet/pbf",
    "/store/planet/planet",
    "/var/log/exim4",
    "/var/spool/exim4"
  ]
end

systemd_service "planetdump-trigger" do
  description "Planet dump trigger"
  user "root"
  exec_start "/usr/local/bin/planetdump-trigger"
  sandbox true
  restrict_address_families "AF_UNIX"
end

service "planetdump-trigger" do
  action [:enable, :start]
  subscribes :restart, "template[/usr/local/bin/planetdump-trigger]"
end
