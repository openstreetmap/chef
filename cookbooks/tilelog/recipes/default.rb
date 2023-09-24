#
# Cookbook:: tilelog
# Recipe:: default
#
# Copyright:: 2014-2022, OpenStreetMap Foundation
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
include_recipe "planet::aws"
include_recipe "python"

passwords = data_bag_item("tilelog", "passwords")

tilelog_directory = "/opt/tilelog"
tilelog_output_directory = node[:tilelog][:output_directory]

python_virtualenv tilelog_directory do
  interpreter "/usr/bin/python3"
end

python_package "tilelog" do
  python_virtualenv tilelog_directory
  python_version "3"
  version "1.7.0"
end

directory tilelog_output_directory do
  user "planet"
  group "planet"
  mode "755"
  recursive true
end

template "/usr/local/bin/tilelog" do
  source "tilelog.erb"
  owner "root"
  group "root"
  mode "755"
  variables :output_dir => tilelog_output_directory,
            :aws_key => passwords["aws_key"]
end

systemd_service "tilelog" do
  description "Tile log analysis"
  user "planet"
  exec_start "/usr/local/bin/tilelog"
  nice 10
  sandbox :enable_network => true
  protect_home "tmpfs"
  bind_paths "/home/planet"
  read_write_paths tilelog_output_directory
end

systemd_timer "tilelog" do
  description "Tile log analysis"
  on_calendar "*-*-* 01:07:00"
end

service "tilelog.timer" do
  action [:enable, :start]
end
