#
# Cookbook:: python
# Resource:: virtualenv
#
# Copyright:: 2019, OpenStreetMap Foundation
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

property :virtualenv_directory, :kind_of => String, :name_property => true

action :create do
  execute "virtualenv-#{new_resource.virtualenv_directory}" do
    command "virtualenv #{new_resource.virtualenv_directory}"
    not_if { ::File.exist?(new_resource.virtualenv_directory) }
  end
end

action :delete do
  directory new_resource.virtualenv_directory do
    action :delete
    recursive true
  end
end
