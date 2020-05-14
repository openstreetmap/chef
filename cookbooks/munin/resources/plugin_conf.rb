#
# Cookbook:: munin
# Resource:: munin_plugin_conf
#
# Copyright:: 2013, OpenStreetMap Foundation
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

property :plugin_conf, :kind_of => String, :name_property => true
property :cookbook, :kind_of => [String, nil]
property :template, :kind_of => String, :required => [:create]
property :variables, :kind_of => Hash, :default => {}
property :restart_munin, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  declare_resource :template, config_file do
    cookbook new_resource.cookbook
    source new_resource.template
    owner "root"
    group "root"
    mode "644"
    variables new_resource.variables.merge(:name => new_resource.plugin_conf)
  end
end

action :delete do
  file config_file do
    action :delete
  end
end

action_class do
  def config_file
    "/etc/munin/plugin-conf.d/#{new_resource.plugin_conf}"
  end
end

def after_created
  notifies :restart, "service[munin-node]" if restart_munin
end
