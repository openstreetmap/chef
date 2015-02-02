#
# Cookbook Name:: apache
# Provider:: apache_site
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

action :create do
  t = template available_name do
    cookbook new_resource.cookbook
    source new_resource.template
    owner "root"
    group "root"
    mode 0644
    variables new_resource.variables.merge(:name => new_resource.name, :directory => site_directory)
    notifies :reload, "service[apache2]" if enabled?
  end

  new_resource.updated_by_last_action(t.updated_by_last_action?)
end

action :enable do
  l = link enabled_name do
    to available_name
    owner "root"
    group "root"
    notifies :reload, "service[apache2]"
  end

  new_resource.updated_by_last_action(l.updated_by_last_action?)
end

action :disable do
  l = link enabled_name do
    action :delete
    notifies :reload, "service[apache2]"
  end

  new_resource.updated_by_last_action(l.updated_by_last_action?)
end

action :delete do
  f = file available_name do
    action :delete
  end

  new_resource.updated_by_last_action(f.updated_by_last_action?)
end

def site_directory
  new_resource.directory || "/var/www/#{new_resource.name}"
end

def available_name
  if node[:lsb][:release].to_f >= 14.04
    "/etc/apache2/sites-available/#{new_resource.name}.conf"
  else
    "/etc/apache2/sites-available/#{new_resource.name}"
  end
end

def enabled_name
  if node[:lsb][:release].to_f >= 14.04
    case new_resource.name
    when "default"
      "/etc/apache2/sites-enabled/000-default.conf"
    else
      "/etc/apache2/sites-enabled/#{new_resource.name}.conf"
    end
  else
    case new_resource.name
    when "default"
      "/etc/apache2/sites-enabled/000-default"
    else
      "/etc/apache2/sites-enabled/#{new_resource.name}"
    end
  end
end

def enabled?
  ::File.exist?(enabled_name)
end
