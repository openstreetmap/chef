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

chef_platform = case node[:platform_version]
                  when "12.10" then "12.04"
                  when "14.04" then "12.04"
                  else node[:platform_version]
                end

chef_package = "chef-server_#{node[:chef][:server][:version]}_amd64.deb"

directory "/var/cache/chef" do
  owner "root"
  group "root"
  mode 0755
end

Dir.glob("/var/cache/chef/chef-server_*.deb").each do |deb|
  if deb != "/var/cache/chef/#{chef_package}"
    file deb do
      action :delete
      backup false
    end
  end
end

remote_file "/var/cache/chef/#{chef_package}" do
  source "https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/#{chef_platform}/x86_64/#{chef_package}"
  owner "root"
  group "root"
  mode 0644
  backup false
end

dpkg_package "chef-erver" do
  source "/var/cache/chef/#{chef_package}"
  version node[:chef][:server][:version]
  notifies :run, "execute[chef-server-reconfigure]"
end

ruby_block "/opt/chef-server/embedded/service/chef-server-webui/app/controllers/status_controller.rb" do
  block do
    rc = Chef::Util::FileEdit.new("/opt/chef-server/embedded/service/chef-server-webui/app/controllers/status_controller.rb")
    rc.search_file_delete(/&rows=20/)
    rc.write_file

    if rc.file_edited?
      resources(:execute => "chef-server-reconfigure").run_action(:run)
    end
  end
end

template "/etc/chef-server/chef-server.rb" do
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

service "chef-server-runsvdir" do
  provider Chef::Provider::Service::Upstart
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
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
