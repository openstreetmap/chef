#
# Cookbook Name:: nodejs
# Provider:: package
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

require "chef/mixin/shell_out"
require "json"

include Chef::Mixin::ShellOut

def load_current_resource
  @packages = JSON.parse(shell_out("npm list --global --json").stdout)["dependencies"] || {}

  @current_resource = Chef::Resource::NodejsPackage.new(new_resource.name)
  @current_resource.package_name(new_resource.package_name)
  if (package = @packages[@current_resource.package_name])
    @current_resource.version(package["version"])
  end
  @current_resource
end

action :install do
  package_name = if new_resource.version
                   "#{new_resource.package_name}@#{new_resource.version}"
                 else
                   new_resource.package_name
                 end

  if !@packages.include?(new_resource.package_name)
    shell_out!("npm install --global #{package_name}")
    new_resource.updated_by_last_action(true)
  elsif new_resource.version &&
        new_resource.version != @current_resource.version
    shell_out!("npm install --global #{package_name}")
    new_resource.updated_by_last_action(true)
  end
end

action :upgrade do
  if @packages.include?(new_resource.package_name)
    shell_out!("npm update --global #{new_resource.package_name}")
    new_resource.updated_by_last_action(true)
  end
end

action :remove do
  if @packages.include?(new_resource.package_name)
    shell_out!("npm remove --global #{new_resource.package_name}")
    new_resource.updated_by_last_action(true)
  end
end
