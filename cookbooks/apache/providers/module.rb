#
# Cookbook Name:: apache
# Provider:: apache_module
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

action :install do
  unless installed?
    package package_name
  end

  if new_resource.conf # ~FC023
    template available_name("conf") do
      source new_resource.conf
      owner "root"
      group "root"
      mode 0o644
      variables new_resource.variables
    end
  end
end

action :enable do
  execute "a2enmod-#{new_resource.name}" do
    command "a2enmod #{new_resource.name}"
    user "root"
    group "root"
    not_if { ::File.exist?(enabled_name("load")) }
  end

  link enabled_name("load") do
    to available_name("load")
    owner "root"
    group "root"
  end

  link enabled_name("conf") do
    to available_name("conf")
    owner "root"
    group "root"
    only_if { ::File.exist?(available_name("conf")) }
  end
end

action :disable do
  link enabled_name("load") do
    action :delete
  end

  link enabled_name("conf") do
    action :delete
  end
end

action :delete do
  package package_name do
    action :remove
  end
end

def package_name
  new_resource.package || "libapache2-mod-#{new_resource.name}"
end

def available_name(extension)
  "/etc/apache2/mods-available/#{new_resource.name}.#{extension}"
end

def enabled_name(extension)
  "/etc/apache2/mods-enabled/#{new_resource.name}.#{extension}"
end

def installed?
  ::File.exist?(available_name("load"))
end
