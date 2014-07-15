#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

package "apache2"
package "apache2-mpm-#{node[:apache][:mpm]}"

#In Apache 2.4 mpm have become runtime loadable modules
#Diable all mpm except the required mpm
if node[:lsb][:release].to_f >= 14.04
  mpms = ['event', 'itk', 'prefork', 'worker']
  mpms.reject{|u| u == node[:apache][:mpm]}.each do |mpm|
    apache_module mpm do
      action [ :disable ]
    end
  end
end

admins = data_bag_item("apache", "admins")

template "/etc/apache2/httpd.conf" do
  source "httpd.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/apache2/ports.conf" do
  source "ports.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

service "apache2" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
  subscribes :restart, "package[apache2-mpm-#{node[:apache][:mpm]}]"
  subscribes :reload, "template[/etc/apache2/httpd.conf]"
end

apache_module "info" do
  conf "info.conf.erb"
  variables :hosts => admins["hosts"]
end

apache_module "status" do
  conf "status.conf.erb"
  variables :hosts => admins["hosts"]
end

apache_module "reqtimeout" do
  action [ :disable ]
end

munin_plugin "apache_accesses"
munin_plugin "apache_processes"
munin_plugin "apache_volume"
