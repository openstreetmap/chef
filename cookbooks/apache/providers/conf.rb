#
# Cookbook Name:: apache
# Provider:: apache_conf
#
# Copyright 2014, OpenStreetMap Foundation
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
  if node[:lsb][:release].to_f >= 14.04
    create_conf
  end
end

action :enable do
  if node[:lsb][:release].to_f >= 14.04
    enable_conf
  else
    create_conf
  end
end

action :disable do
  if node[:lsb][:release].to_f >= 14.04
    disable_conf
  else
    delete_conf
  end
end

action :delete do
  if node[:lsb][:release].to_f >= 14.04
    delete_conf
  end
end

def create_conf
  t = template available_name do
    cookbook new_resource.cookbook
    source new_resource.template
    owner "root"
    group "root"
    mode 0644
    variables new_resource.variables
    notifies :reload, "service[apache2]" if enabled? or available_name == enabled_name
  end

  new_resource.updated_by_last_action(t.updated_by_last_action?)
end

def enable_conf
  l = link enabled_name do
    to available_name
    owner "root"
    group "root"
    notifies :reload, "service[apache2]"
  end

  new_resource.updated_by_last_action(l.updated_by_last_action?)
end

def disable_conf
  l = link enabled_name do
    action :delete
    notifies :reload, "service[apache2]"
  end

  new_resource.updated_by_last_action(l.updated_by_last_action?)
end

def delete_conf
  f = file available_name do
    action :delete
  end

  new_resource.updated_by_last_action(f.updated_by_last_action?)
end

def available_name
  if node[:lsb][:release].to_f >= 14.04
    "/etc/apache2/conf-available/#{new_resource.name}"
  else
    "/etc/apache2/conf.d/#{new_resource.name}"
  end
end

def enabled_name
  if node[:lsb][:release].to_f >= 14.04
    "/etc/apache2/conf-enabled/#{new_resource.name}"
  else
    "/etc/apache2/conf.d/#{new_resource.name}"
  end
end

def enabled?
  ::File.exists?(enabled_name)
end
