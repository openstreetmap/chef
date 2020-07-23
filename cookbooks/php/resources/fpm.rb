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
property :port, :kind_of => Integer
property :user, :kind_of => String, :default => "www-data"
property :group, :kind_of => String, :default => "www-data"
property :pm, :kind_of => String, :default => "dynamic"
property :pm_max_children, :kind_of => Integer, :default => 5
property :pm_start_servers, :kind_of => Integer, :default => 2
property :pm_min_spare_servers, :kind_of => Integer, :default => 1
property :pm_max_spare_servers, :kind_of => Integer, :default => 3
property :pm_max_requests, :kind_of => Integer, :default => 500
property :request_terminate_timeout, :kind_of => Integer, :default => 0
property :environment, :kind_of => Hash, :default => {}
property :php_values, :kind_of => Hash, :default => {}
property :php_admin_values, :kind_of => Hash, :default => {}
property :php_flags, :kind_of => Hash, :default => {}
property :php_admin_flags, :kind_of => Hash, :default => {}
property :reload_fpm, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  template conf_file do
    cookbook "php"
    source "pool.conf.erb"
    owner "root"
    group "root"
    mode "644"
    variables new_resource.to_hash
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
