#
# Cookbook:: chef
# Recipe:: default
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

cache_dir = Chef::Config[:file_cache_path]

chef_version = node[:chef][:client][:version]
chef_package = "chef_#{chef_version}-1_amd64.deb"

directory "/var/cache/chef" do
  action :delete
  recursive true
end

Dir.glob("#{cache_dir}/chef_*.deb").each do |deb|
  next if deb == "#{cache_dir}/#{chef_package}"

  file deb do
    action :delete
    backup false
  end
end

remote_file "#{cache_dir}/#{chef_package}" do
  source "https://packages.chef.io/files/stable/chef/#{chef_version}/ubuntu/#{node[:lsb][:release]}/#{chef_package}"
  owner "root"
  group "root"
  mode "644"
  backup false
  ignore_failure true
end

dpkg_package "chef" do
  source "#{cache_dir}/#{chef_package}"
  version "#{chef_version}-1"
end

directory "/etc/chef" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/chef/client.rb" do
  source "client.rb.erb"
  owner "root"
  group "root"
  mode "640"
end

file "/etc/chef/client.pem" do
  owner "root"
  group "root"
  mode "400"
end

template "/etc/chef/report.rb" do
  source "report.rb.erb"
  owner "root"
  group "root"
  mode "644"
end

template "/etc/logrotate.d/chef" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/etc/chef/trusted_certs" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/chef/trusted_certs/verisign.pem" do
  source "verisign.pem.erb"
  owner "root"
  group "root"
  mode "644"
end

directory node[:ohai][:plugin_dir] do
  owner "root"
  group "root"
  mode "755"
end

directory "/var/log/chef" do
  owner "root"
  group "root"
  mode "755"
end

systemd_service "chef-client" do
  description "Chef client"
  exec_start "/usr/bin/chef-client"
end

systemd_timer "chef-client" do
  description "Chef client"
  after "network.target"
  on_active_sec 60
  on_unit_inactive_sec 25 * 60
  randomized_delay_sec 10 * 60
end

service "chef-client.timer" do
  action [:enable, :start]
end

service "chef-client.service" do
  action :disable
  subscribes :stop, "service[chef-client.timer]"
end
