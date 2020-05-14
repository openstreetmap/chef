#
# Cookbook:: systemd
# Resource:: systemd_path
#
# Copyright:: 2017, OpenStreetMap Foundation
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

default_action :create

property :path, String, :name_property => true
property :description, String, :required => [:create]
property :after, [String, Array]
property :wants, [String, Array]
property :path_exists, [String, Array]
property :path_exists_glob, [String, Array]
property :path_changed, [String, Array]
property :path_modified, [String, Array]
property :directory_not_empty, [String, Array]
property :unit, String
property :make_directory, [true, false]
property :directory_mode, Integer

action :create do
  path_variables = new_resource.to_hash

  template "/etc/systemd/system/#{new_resource.path}.path" do
    cookbook "systemd"
    source "path.erb"
    owner "root"
    group "root"
    mode "644"
    variables path_variables
  end

  execute "systemctl-reload-#{new_resource.path}.path" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "template[/etc/systemd/system/#{new_resource.path}.path]"
  end
end

action :delete do
  file "/etc/systemd/system/#{new_resource.path}.path" do
    action :delete
  end

  execute "systemctl-reload-#{new_resource.path}.path" do
    action :nothing
    command "systemctl daemon-reload"
    user "root"
    group "root"
    subscribes :run, "file[/etc/systemd/system/#{new_resource.path}.path]"
  end
end
