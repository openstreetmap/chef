#
# Cookbook:: ruby
# Resource:: bundle_install
#
# Copyright:: 2022, OpenStreetMap Foundation
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

resource_name :bundle_install
provides :bundle_install

unified_mode true

default_action :run

property :directory, :kind_of => String, :name_property => true
property :options, :kind_of => String
property :user, :kind_of => String
property :group, :kind_of => String
property :environment, :kind_of => Hash

action :run do
  execute "#{new_resource.directory}/Gemfile" do
    command "#{bundle_command} install #{new_resource.options}"
    cwd new_resource.directory
    user new_resource.user
    group new_resource.group
    environment new_resource.environment
  end
end

action_class do
  def bundle_command
    node[:ruby][:bundle]
  end
end

def after_created
  subscribes :run, "gem_package[bundler#{node[:ruby][:version]}-1]"
  subscribes :run, "gem_package[bundler#{node[:ruby][:version]}-2]"
end
