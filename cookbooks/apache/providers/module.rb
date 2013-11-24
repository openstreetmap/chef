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

action :install do
  p = package package_name do
    action :install
    not_if { ::File.exists?(available_name("load")) }
  end

  updated = p.updated_by_last_action?

  if new_resource.conf
    t = template available_name("conf") do
      source new_resource.conf
      owner "root"
      group "root"
      mode 0644
      variables new_resource.variables
      notifies :reload, "service[apache2]" if enabled?
    end

    updated = updated || t.updated_by_last_action?
  end

  new_resource.updated_by_last_action(updated)
end

action :enable do
  l = link enabled_name("load") do
    to available_name("load")
    owner "root"
    group "root"
    notifies :restart, "service[apache2]"
  end

  c = link enabled_name("conf") do
    to available_name("conf")
    owner "root"
    group "root"
    notifies :reload, "service[apache2]"
    only_if { ::File.exists?(available_name("conf")) }
  end

  new_resource.updated_by_last_action(l.updated_by_last_action? || c.updated_by_last_action?)
end

action :disable do
  l = link enabled_name("load") do
    action :delete
    notifies :restart, "service[apache2]"
  end

  c = link enabled_name("conf") do
    action :delete
    notifies :reload, "service[apache2]"
  end

  new_resource.updated_by_last_action(l.updated_by_last_action? || c.updated_by_last_action?)
end

action :delete do
  p = package package_name do
    action :remove
  end

  new_resource.updated_by_last_action(p.updated_by_last_action?)
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

def enabled?
  ::File.exists?(enabled_name("load"))
end
