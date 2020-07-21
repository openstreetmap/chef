#
# Cookbook:: tilelog
# Recipe:: default
#
# Copyright:: 2014, OpenStreetMap Foundation
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
include_recipe "tools"

package %w[
  gcc
  g++
  make
  autoconf
  automake
  libboost-filesystem-dev
  libboost-program-options-dev
  libboost-system-dev
]

tilelog_source_directory = node[:tilelog][:source_directory]
tilelog_input_directory = node[:tilelog][:input_directory]
tilelog_output_directory = node[:tilelog][:output_directory]

# resources for building the tile analysis binary
git tilelog_source_directory do
  action :sync
  repository "https://github.com/zerebubuth/openstreetmap-tile-analyze.git"
  revision "live"
  user "root"
  group "root"
  notifies :run, "execute[tilelog-autogen]", :immediately
end

execute "tilelog-autogen" do
  action :nothing
  command "autoreconf -i"
  cwd tilelog_source_directory
  user "root"
  group "root"
  notifies :run, "execute[tilelog-configure]", :immediately
end

execute "tilelog-configure" do
  action :nothing
  command "./configure --with-boost-libdir=/usr/lib/x86_64-linux-gnu"
  cwd tilelog_source_directory
  user "root"
  group "root"
  notifies :run, "execute[tilelog-build]", :immediately
end

execute "tilelog-build" do
  action :nothing
  command "make"
  cwd tilelog_source_directory
  user "root"
  group "root"
end

# resources for running the tile analysis
template "/usr/local/bin/tilelog" do
  source "tilelog.erb"
  owner "root"
  group "root"
  mode "755"
  variables :analyze_bin => "#{tilelog_source_directory}/openstreetmap-tile-analyze",
            :input_dir => tilelog_input_directory,
            :output_dir => tilelog_output_directory
end

cron_d "tilelog" do
  minute "17"
  hour "22"
  user "www-data"
  command "/usr/local/bin/tilelog"
  mailto "zerebubuth@gmail.com"
end

# resources related to the output of the analysis and where it
# can be publicly downloaded.
directory tilelog_output_directory do
  user "www-data"
  group "www-data"
  mode "755"
  recursive true
end
