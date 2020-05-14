#
# Cookbook:: ohai
# Resource:: ohai_plugin
#
# Copyright:: 2015, OpenStreetMap Foundation
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

property :plugin, :kind_of => String, :name_property => true
property :template, :kind_of => String, :required => [:create]

action :create do
  ohai new_resource.plugin do
    action :nothing
  end

  directory "/etc/chef/ohai" do
    owner "root"
    group "root"
    mode "755"
    recursive true
  end

  declare_resource :template, plugin_path do
    source new_resource.template
    owner "root"
    group "root"
    mode "644"
    notifies :reload, "ohai[#{new_resource.plugin}]"
  end
end

action :delete do
  file plugin_path do
    action :delete
  end
end

action_class do
  def plugin_path
    "/etc/chef/ohai/#{new_resource.plugin}.rb"
  end
end
