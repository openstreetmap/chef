#
# Cookbook Name:: python
# Resource:: package
#
# Copyright 2017, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :install

attribute :package_name, :kind_of => String, :name_attribute => true
attribute :version, :kind_of => String

action :install do
  if version.nil?
    execute "pip-install-#{name}" do
      command "pip install #{new_resource.package_name}"
      not_if "pip show #{new_resource.package_name}"
    end
  else
    execute "pip-install-#{name}" do
      command "pip install #{new_resource.package_name}==#{new_resource.version}"
      not_if "pip show #{new_resource.package_name} | fgrep -q #{new_resource.version}"
    end
  end
end

action :remove do
  execute "pip-uninstall-#{name}" do
    command "pip uninstall #{new_resource.package_name}"
    only_if "pip show #{new_resource.package_name}"
  end
end
