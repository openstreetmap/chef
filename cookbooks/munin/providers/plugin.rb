#
# Cookbook Name:: munin
# Provider:: munin_plugin
#
# Copyright 2013, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  link_action = case target_path
                when nil then :delete
                else :create
                end

  link plugin_path do
    action link_action
    to target_path
  end

  if new_resource.conf # ~FC023
    munin_plugin_conf new_resource.name do
      cookbook new_resource.conf_cookbook
      template new_resource.conf
      variables new_resource.conf_variables
    end
  end
end

action :delete do
  link plugin_path do
    action :delete
  end

  if new_resource.conf # ~FC023
    munin_plugin_conf new_resource.name do
      action :delete
    end
  end
end

def plugin_path
  "/etc/munin/plugins/#{new_resource.name}"
end

def target_path
  case
  when ::File.exist?(target)
    target
  when ::File.exist?("/usr/local/share/munin/plugins/#{target}")
    "/usr/local/share/munin/plugins/#{target}"
  when ::File.exist?("/usr/share/munin/plugins/#{target}")
    "/usr/share/munin/plugins/#{target}"
  end
end

def target
  new_resource.target || new_resource.name
end
