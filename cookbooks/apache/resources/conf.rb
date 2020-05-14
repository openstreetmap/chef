#
# Cookbook:: apache
# Resource:: apache_conf
#
# Copyright:: 2014, OpenStreetMap Foundation
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

default_action [:create, :enable]

property :conf, :kind_of => String, :name_property => true
property :cookbook, :kind_of => String
property :template, :kind_of => String, :required => [:create]
property :variables, :kind_of => Hash, :default => {}
property :reload_apache, :kind_of => [TrueClass, FalseClass], :default => true

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

action_class do
  def create_conf
    declare_resource :template, available_name do
      cookbook new_resource.cookbook
      source new_resource.template
      owner "root"
      group "root"
      mode "644"
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
    "/etc/apache2/conf-available/#{new_resource.conf}.conf"
  end

  def enabled_name
    "/etc/apache2/conf-enabled/#{new_resource.conf}.conf"
  end
end

def after_created
  notifies :reload, "service[apache2]" if reload_apache
end
