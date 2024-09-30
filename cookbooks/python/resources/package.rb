#
# Cookbook:: python
# Resource:: package
#
# Copyright:: 2017, OpenStreetMap Foundation
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

unified_mode true

default_action :install

property :package_name, :kind_of => String, :name_property => true
property :version, :kind_of => String
property :python_version, :kind_of => String
property :python_virtualenv, :kind_of => String
property :extra_index_url, :kind_of => String

action :install do
  if new_resource.version.nil?
    execute "pip-install-#{new_resource.package_name}" do
      command "#{pip_command} install #{pip_extra_index} #{new_resource.package_name}"
      not_if "#{pip_command} show #{new_resource.package_name}"
    end
  else
    execute "pip-install-#{new_resource.package_name}" do
      command "#{pip_command} install #{pip_extra_index} #{new_resource.package_name}==#{new_resource.version}"
      not_if "#{pip_command} show #{new_resource.package_name} | fgrep -q #{new_resource.version}"
    end
  end
end

action :upgrade do
  if new_resource.version.nil?
    execute "pip-upgrade-#{new_resource.package_name}" do
      command "#{pip_command} install #{pip_extra_index} --upgrade #{new_resource.package_name}"
      only_if "#{pip_command} list --outdated | fgrep -q #{new_resource.package_name}"
    end
  else
    execute "pip-upgrade-#{new_resource.package_name}" do
      command "#{pip_command} install #{pip_extra_index} --upgrade #{new_resource.package_name}==#{new_resource.version}"
      not_if "#{pip_command} show #{new_resource.package_name} | fgrep -q #{new_resource.version}"
    end
  end
end

action :remove do
  execute "pip-uninstall-#{new_resource.package_name}" do
    command "#{pip_command} uninstall #{new_resource.package_name}"
    only_if "#{pip_command} show #{new_resource.package_name}"
  end
end

action_class do
  def pip_extra_index
    if new_resource.extra_index_url
      "--extra-index-url '#{new_resource.extra_index_url}'"
    end
  end

  def pip_command
    if new_resource.python_virtualenv
      "#{new_resource.python_virtualenv}/bin/pip"
    else
      "pip#{new_resource.python_version}"
    end
  end
end
