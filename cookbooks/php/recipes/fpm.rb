#
# Cookbook:: php
# Recipe:: fpm
#
# Copyright:: 2020, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "php"
include_recipe "prometheus"

package "php-fpm"

template "/etc/php/#{node[:php][:version]}/fpm/conf.d/99-chef.ini" do
  source "php-fpm.ini.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[php#{node[:php][:version]}-fpm]"
end

service "php#{node[:php][:version]}-fpm" do
  action [:enable, :start]
end

