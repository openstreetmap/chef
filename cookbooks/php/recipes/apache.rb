#
# Cookbook:: php
# Recipe:: apache
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

include_recipe "apache"
include_recipe "php::fpm"

apache_module "proxy"
apache_module "proxy_fcgi"

apache_module "php#{node[:php][:version]}" do
  action :disable
end

apache_conf "php#{node[:php][:version]}-fpm" do
  action :enable
end
