#
# Cookbook Name:: postgresql
# Provider:: postgresql_database
#
# Copyright 2012, OpenStreetMap Foundation
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
    if enabled?
      notifies :reload, "service[apache2]"
    end
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
  "/etc/apache2/sites-available/#{new_resource.name}"
end

def enabled_name
  case new_resource.name
  when "default"
    "/etc/apache2/sites-enabled/000-default"
  else
    "/etc/apache2/sites-enabled/#{new_resource.name}"
  end
end

def enabled?
  ::File.exists?(enabled_name)
end
