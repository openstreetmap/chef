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

use_inline_resources

action :create do
  create_conf
end

action :enable do
  enable_conf
end

action :disable do
  disable_conf
end

action :delete do
  delete_conf
end

def create_conf
  template available_name do
    cookbook new_resource.cookbook
    source new_resource.template
    owner "root"
    group "root"
    mode 0o644
    variables new_resource.variables
  end
end

def enable_conf
  link enabled_name do
    to available_name
    owner "root"
    group "root"
  end
end

def disable_conf
  link enabled_name do
    action :delete
  end
end

def delete_conf
  file available_name do
    action :delete
  end
end

def available_name
  "/etc/apache2/conf-available/#{new_resource.name}.conf"
end

def enabled_name
  "/etc/apache2/conf-enabled/#{new_resource.name}.conf"
end
