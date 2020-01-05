#
# Cookbook:: nodejs
# Resource:: package
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

require "json"

default_action :install

property :package, :kind_of => String, :name_property => true
property :version, :kind_of => String

action :install do
  qualified_name = if new_resource.version
                     "#{new_resource.package}@#{new_resource.version}"
                   else
                     new_resource.package
                   end

  if current_version.nil?
    converge_by "install #{qualified_name}" do
      shell_out!("npm install --global #{qualified_name}")
    end
  elsif new_resource.version &&
        new_resource.version != current_version
    converge_by "update #{qualified_name}" do
      shell_out!("npm install --global #{qualified_name}")
    end
  end
end

action :upgrade do
  unless current_version.nil?
    converge_by "update #{new_resource.package}" do
      shell_out!("npm update --global #{new_resource.package}")
    end
  end
end

action :remove do
  unless current_version.nil?
    converge_by "remove #{new_resource.package}" do
      shell_out!("npm remove --global #{new_resource.package}")
    end
  end
end

action_class do
  def current_version
    @current_version ||= JSON.parse(shell_out("npm list --global --json").stdout)
                             .dig("dependencies", new_resource.package, "version")
  end
end
