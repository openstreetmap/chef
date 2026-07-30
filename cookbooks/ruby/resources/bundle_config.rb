#
# Cookbook:: ruby
# Resource:: bundle_config
#
# Copyright:: 2025, OpenStreetMap Foundation
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

resource_name :bundle_config
provides :bundle_config

unified_mode true

default_action :create

property :directory, :kind_of => String, :name_property => true
property :user, :kind_of => String
property :group, :kind_of => String
property :settings, :kind_of => Hash

load_current_value do |new_resource|
  current_settings = shell_out!("#{node[:ruby][:bundle]} config list --parseable", :cwd => new_resource.directory).stdout.split("\n").map do |line|
    line.split("=")
  end.to_h

  settings current_settings
end

action :create do
  converge_if_changed :settings do
    new_resource.settings.each do |name, value|
      execute "bundle-config-set-#{name}" do
        command "#{bundle_command} config set --local #{name} #{value}"
        cwd new_resource.directory
        user new_resource.user
        group new_resource.group
      end
    end
  end
end

action_class do
  def bundle_command
    node[:ruby][:bundle]
  end
end
