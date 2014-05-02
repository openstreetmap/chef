#
# Cookbook Name:: chef
# Recipe:: default
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

chef_gem "pony"

chef_package = "chef_#{node[:chef][:client][:version]}_amd64.deb"

chef_platform = case node[:platform_version]
                  when "12.10" then "12.04"
                  else node[:platform_version]
                end

directory "/var/cache/chef" do
  owner "root"
  group "root"
  mode 0755
end

Dir.glob("/var/cache/chef/chef_*.deb").each do |deb|
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
  ignore_failure true
end

dpkg_package "chef" do
  source "/var/cache/chef/#{chef_package}"
  version node[:chef][:client][:version]
end

template "/etc/init/chef-client.conf" do
  source "chef-client.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/etc/chef" do
  owner "root"
  group "root"
  mode 0755
end

template "/etc/chef/client.rb" do
  source "client.rb.erb"
  owner "root"
  group "root"
  mode 0640
end

file "/etc/chef/client.pem" do
  owner "root"
  group "root"
  mode 0400
end

template "/etc/chef/report.rb" do
  source "report.rb.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/logrotate.d/chef" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/etc/chef/ohai" do
  owner "root"
  group "root"
  mode 0755
end

directory "/var/log/chef" do
  owner "root"
  group "root"
  mode 0755
end

service "chef-client" do
  provider Chef::Provider::Service::Upstart
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
  subscribes :restart, "dpkg_package[chef]"
  subscribes :restart, "template[/etc/init/chef-client.conf]"
  subscribes :restart, "template[/etc/chef/client.rb]"
  subscribes :restart, "template[/etc/chef/report.rb]"
end
