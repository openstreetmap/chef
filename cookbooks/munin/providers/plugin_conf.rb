#
# Cookbook Name:: munin
# Provider:: munin_plugin_conf
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
  template config_file do
    cookbook new_resource.cookbook
    source new_resource.template
    owner "root"
    group "root"
    mode 0644
    variables new_resource.variables.merge(:name => new_resource.name)
  end
end

action :delete do
  file config_file do
    action :delete
  end
end

def config_file
  "/etc/munin/plugin-conf.d/#{new_resource.name}"
end
