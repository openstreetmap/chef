#
# Cookbook:: mysql
# Recipe:: default
#
# Copyright:: 2013, OpenStreetMap Foundation
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

include_recipe "prometheus"

mysql_variant = if platform?("ubuntu")
                  "mysql"
                else
                  "mariadb"
                end

package "#{mysql_variant}-server"
package "#{mysql_variant}-client"

service "#{mysql_variant}" do
  action [:enable, :start]
  supports :status => true, :restart => true
end

template "/etc/mysql/#{mysql_variant}.conf.d/zzz-chef.cnf" do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[#{mysql_variant}]"
end

service "apparmor" do
  action :nothing
end

template "/etc/apparmor.d/local/usr.sbin.mysqld" do
  source "apparmor.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[apparmor]"
  only_if { ::Dir.exist?("/sys/kernel/security/apparmor") }
end

mysql_password = persistent_token("mysql", "prometheus", "password")

mysql_user "prometheus" do
  password mysql_password
  process true
  repl_client true
end

prometheus_exporter "mysqld" do
  port 9104
  options "--mysqld.username=prometheus"
  environment "MYSQLD_EXPORTER_PASSWORD" => mysql_password
end
