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

include_recipe "ssl"

package %w[
  apache2
  libwww-perl
]

%w[event itk prefork worker].each do |mpm|
  if mpm == node[:apache][:mpm]
    apache_module "mpm_#{mpm}" do
      action [:enable]
    end
  else
    apache_module "mpm_#{mpm}" do
      action [:disable]
    end
  end
end

admins = data_bag_item("apache", "admins")

apache_conf "httpd" do
  template "httpd.conf.erb"
  notifies :reload, "service[apache2]"
end

template "/etc/apache2/ports.conf" do
  source "ports.conf.erb"
  owner "root"
  group "root"
  mode 0o644
end

service "apache2" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

apache_module "info" do
  conf "info.conf.erb"
  variables :hosts => admins["hosts"]
end

apache_module "status" do
  conf "status.conf.erb"
  variables :hosts => admins["hosts"]
end

apache_module "deflate" do
  conf "deflate.conf.erb"
end

if node[:apache][:reqtimeout]
  apache_module "reqtimeout" do
    action [:enable]
  end
else
  apache_module "reqtimeout" do
    action [:disable]
  end
end

apache_module "headers"
apache_module "ssl"

apache_conf "ssl" do
  template "ssl.erb"
end

munin_plugin "apache_accesses"
munin_plugin "apache_processes"
munin_plugin "apache_volume"
