#
# Cookbook:: munin
# Provider:: munin_plugin
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

default_action :create

property :plugin, :kind_of => String, :name_property => true
property :target, :kind_of => String
property :conf, :kind_of => String
property :conf_cookbook, :kind_of => String
property :conf_variables, :kind_of => Hash, :default => {}
property :restart_munin, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  link_action = case target_path
                when nil then :delete
                else :create
                end

  link plugin_path do
    action link_action
    to target_path
  end

  if new_resource.conf
    munin_plugin_conf new_resource.plugin do
      cookbook new_resource.conf_cookbook
      template new_resource.conf
      variables new_resource.conf_variables
      restart_munin false
    end
  end
end

action :delete do
  link plugin_path do
    action :delete
  end

  if new_resource.conf
    munin_plugin_conf new_resource.plugin do
      action :delete
      restart_munin false
    end
  end
end

action_class do
  def plugin_path
    "/etc/munin/plugins/#{new_resource.plugin}"
  end

  def target_path
    if ::File.exist?(target)
      target
    elsif ::File.exist?("/usr/local/share/munin/plugins/#{target}")
      "/usr/local/share/munin/plugins/#{target}"
    elsif ::File.exist?("/usr/share/munin/plugins/#{target}")
      "/usr/share/munin/plugins/#{target}"
    end
  end

  def target
    new_resource.target || new_resource.plugin
  end
end

def after_created
  notifies :restart, "service[munin-node]" if restart_munin
end
