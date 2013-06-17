#
# Cookbook Name:: nominatim
# Recipe:: default
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

include_recipe "apache"
include_recipe "postgresql"

package "php5"
package "php5-cli"
package "php5-pgsql"

package "php-apc"

apache_module "rewrite"
apache_module "fastcgi-handler"

service "php5-fpm" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
end

postgresql_user "tomh" do
  cluster "9.1/main"
  superuser true
end

postgresql_user "lonvia" do
  cluster "9.1/main"
  superuser true
end

postgresql_user "twain" do
  cluster "9.1/main"
  superuser true
end

postgresql_user "www-data" do
  cluster "9.1/main"
end

postgresql_munin "nominatim" do
  cluster "9.1/main"
  database "nominatim"
end
