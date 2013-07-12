#
# Cookbook Name:: chef
# Recipe:: server
#
# Copyright 2010, OpenStreetMap Foundation
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

include_recipe "apache::ssl"

service "chef-server-runsvdir" do
  provider Chef::Provider::Service::Upstart
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
end

apache_module "alias"
apache_module "proxy_http"

execute "chef-server-reconfigure" do
  action :nothing
  command "chef-server-ctl reconfigure"
  user "root"
  group "root"
end

template "/etc/chef-server/chef-server.rb" do
  source "server.rb.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :run, "execute[chef-server-reconfigure]"
end

apache_site "chef.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/cron.daily/chef-server-backup" do
  source "server-backup.cron.erb"
  owner "root"
  group "root"
  mode 0755
end
