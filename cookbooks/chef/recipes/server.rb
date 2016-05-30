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

# chef_package = "chef-server-core_#{node[:chef][:server][:version]}_amd64.deb"
#
# directory "/var/cache/chef" do
#   owner "root"
#   group "root"
#   mode 0755
# end
#
# Dir.glob("/var/cache/chef/chef-server-core_*.deb").each do |deb|
#   next if deb == "/var/cache/chef/#{chef_package}"

#   file deb do
#     action :delete
#     backup false
#   end
# end
#
# remote_file "/var/cache/chef/#{chef_package}" do
#   source "https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/#{node[:lsb][:codename]}/#{chef_package}"
#   owner "root"
#   group "root"
#   mode 0644
#   backup false
# end
#
# dpkg_package "chef-server-core" do
#   source "/var/cache/chef/#{chef_package}"
#   version node[:chef][:server][:version]
#   notifies :run, "execute[chef-server-reconfigure]"
# end

template "/etc/opscode/chef-server.rb" do
  source "server.rb.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :run, "execute[chef-server-reconfigure]"
end

execute "chef-server-reconfigure" do
  action :nothing
  command "chef-server-ctl reconfigure"
  user "root"
  group "root"
end

systemd_service "chef-server" do
  description "Chef server"
  after "network.target"
  exec_start "/opt/opscode/embedded/bin/runsvdir-start"
end

service "chef-server" do
  action [:enable, :start]
end

apache_module "alias"
apache_module "proxy_http"

apache_site "chef.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/cron.daily/chef-server-backup" do
  source "server-backup.cron.erb"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/logrotate.d/chef-server" do
  source "logrotate.server.erb"
  owner "root"
  group "root"
  mode 0644
end

munin_plugin "chef_status"
