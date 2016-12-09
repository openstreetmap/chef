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

chef_version = node[:chef][:client][:version]
chef_package = "chef_#{chef_version}-1_amd64.deb"

directory "/var/cache/chef" do
  owner "root"
  group "root"
  mode 0o755
end

Dir.glob("/var/cache/chef/chef_*.deb").each do |deb|
  next if deb == "/var/cache/chef/#{chef_package}"

  file deb do
    action :delete
    backup false
  end
end

remote_file "/var/cache/chef/#{chef_package}" do
  source "https://packages.chef.io/files/stable/chef/#{chef_version}/ubuntu/16.04/#{chef_package}"
  owner "root"
  group "root"
  mode 0o644
  backup false
  ignore_failure true
end

dpkg_package "chef" do
  source "/var/cache/chef/#{chef_package}"
  version "#{chef_version}-1"
end

directory "/etc/chef" do
  owner "root"
  group "root"
  mode 0o755
end

template "/etc/chef/client.rb" do
  source "client.rb.erb"
  owner "root"
  group "root"
  mode 0o640
end

file "/etc/chef/client.pem" do
  owner "root"
  group "root"
  mode 0o400
end

template "/etc/chef/report.rb" do
  source "report.rb.erb"
  owner "root"
  group "root"
  mode 0o644
end

template "/etc/logrotate.d/chef" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode 0o644
end

directory "/etc/chef/trusted_certs" do
  owner "root"
  group "root"
  mode 0o755
end

template "/etc/chef/trusted_certs/verisign.pem" do
  source "verisign.pem.erb"
  owner "root"
  group "root"
  mode 0o644
end

directory node[:ohai][:plugin_dir] do
  owner "root"
  group "root"
  mode 0o755
end

directory "/var/log/chef" do
  owner "root"
  group "root"
  mode 0o755
end

if node[:lsb][:release].to_f >= 15.10
  systemd_service "chef-client" do
    description "Chef client"
    after "network.target"
    exec_start "/usr/bin/chef-client -i 1800 -s 20"
    restart "on-failure"
  end

  service "chef-client" do
    provider Chef::Provider::Service::Systemd
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
    subscribes :restart, "dpkg_package[chef]"
    subscribes :restart, "systemd_service[chef-client]"
    subscribes :restart, "template[/etc/chef/client.rb]"
    subscribes :restart, "template[/etc/chef/report.rb]"
  end
else
  template "/etc/init/chef-client.conf" do
    source "chef-client.conf.erb"
    owner "root"
    group "root"
    mode 0o644
  end

  service "chef-client" do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
    subscribes :restart, "dpkg_package[chef]"
    subscribes :restart, "template[/etc/init/chef-client.conf]"
    subscribes :restart, "template[/etc/chef/client.rb]"
    subscribes :restart, "template[/etc/chef/report.rb]"
  end
end
