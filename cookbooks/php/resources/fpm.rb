#
# Cookbook:: php
# Resource:: php_fpm
#
# Copyright:: 2020, OpenStreetMap Foundation
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

default_action :create

property :pool, :kind_of => String, :name_property => true
property :cookbook, :kind_of => String
property :template, :kind_of => String, :required => true
property :variables, :kind_of => Hash, :default => {}
property :reload_fpm, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  declare_resource :template, conf_file do
    cookbook new_resource.cookbook
    source new_resource.template
    owner "root"
    group "root"
    mode 0o644
    variables new_resource.variables
  end
end

action :delete do
  file conf_file do
    action :delete
  end
end

action_class do
  def php_version
    node[:php][:version]
  end

  def conf_file
    "/etc/php/#{php_version}/fpm/pool.d/#{new_resource.pool}.conf"
  end
end

def after_created
  notifies :reload, "service[php#{node[:php][:version]}-fpm]" if reload_fpm
end
