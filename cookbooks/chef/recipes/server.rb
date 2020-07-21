#
# Cookbook:: chef
# Recipe:: server
#
# Copyright:: 2010, OpenStreetMap Foundation
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
include_recipe "munin"

# cache_dir = Chef::Config[:file_cache_path]
#
# chef_version = node[:chef][:server][:version]
# chef_package = "chef-server-core_#{chef_version}-1_amd64.deb"
#
# Dir.glob("#{cache_dir}/chef-server-core_*.deb").each do |deb|
#   next if deb == "#{cache_dir}/#{chef_package}"
#
#   file deb do
#     action :delete
#     backup false
#   end
# end
#
# remote_file "#{cache_dir}/#{chef_package}" do
#   source "https://packages.chef.io/files/stable/chef-server/#{chef_version}/ubuntu/16.04/#{chef_package}"
#   owner "root"
#   group "root"
#   mode 0644
#   backup false
# end
#
# dpkg_package "chef-server-core" do
#   source "#{cache_dir}/#{chef_package}"
#   version "#{chef_version}-1"
#   notifies :run, "execute[chef-server-reconfigure]"
# end

template "/etc/opscode/chef-server.rb" do
  source "server.rb.erb"
  owner "root"
  group "root"
  mode "640"
  notifies :run, "execute[chef-server-reconfigure]"
end

execute "chef-server-reconfigure" do
  action :nothing
  command "chef-server-ctl reconfigure"
  user "root"
  group "root"
end

execute "chef-server-restart" do
  action :nothing
  command "chef-server-ctl restart"
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
  subscribes :restart, "systemd_service[chef-server]"
end

apache_module "alias"
apache_module "proxy_http"

ssl_certificate "chef.openstreetmap.org" do
  domains ["chef.openstreetmap.org", "chef.osm.org"]
  notifies :reload, "service[apache2]"
  notifies :run, "execute[chef-server-restart]"
end

apache_site "chef.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/cron.daily/chef-server-backup" do
  source "server-backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end

munin_plugin "chef_status"
