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

chef_name = if node[:chef][:client][:cinc]
              "cinc"
            else
              "chef"
            end

chef_version = node[:chef][:client][:version]

chef_platform = if platform?("debian")
                  "debian"
                else
                  "ubuntu"
                end

chef_arch = if arm?
              "arm64"
            else
              "amd64"
            end

if node[:chef][:client][:cinc]
  os_release = node[:lsb][:release]
else
  os_release = if platform?("debian") && node[:lsb][:release].to_f > 11
                 11
               else
                 node[:lsb][:release]
               end

  # Chef is currently not available for Debian 11 on arm64.
  if chef_platform == "debian" && os_release == 11 && chef_arch == "arm64"
    chef_platform = "ubuntu"
    os_release = "22.04"
  end
end

chef_package = "#{chef_name}_#{chef_version}-1_#{chef_arch}.deb"

chef_url = if node[:chef][:client][:cinc]
             "https://downloads.cinc.sh/files/stable/cinc"
           else
             "https://packages.chef.io/files/stable/chef"
           end

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

if node[:chef][:client][:cinc]
  service "chef-client.timer" do
    action [:disable, :stop]
  end

  systemd_timer "chef-client" do
    action :delete
  end

  systemd_service "chef-client" do
    action :delete
  end

  file "/etc/logrotate.d/chef" do
    action :delete
  end

  if node[:packages][:cinc]
    package "chef" do
      action :purge
    end

    directory "/etc/chef" do
      action :delete
      recursive true
    end

    directory "/var/chef" do
      action :delete
      recursive true
    end

    directory "/var/log/chef" do
      action :delete
      recursive true
    end

    directory "/opt/chef" do
      action :delete
      recursive true
    end
  end
end

remote_file "#{cache_dir}/#{chef_package}" do
  source "#{chef_url}/#{chef_version}/#{chef_platform}/#{os_release}/#{chef_package}"
  owner "root"
  group "root"
  mode "644"
  backup false
  ignore_failure true
end

dpkg_package chef_name do
  source "#{cache_dir}/#{chef_package}"
  version "#{chef_version}-1"
end

directory "/etc/#{chef_name}" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/#{chef_name}/client.rb" do
  source "client.rb.erb"
  owner "root"
  group "root"
  mode "640"
  variables :chef_name => chef_name
end

if node[:chef][:client][:cinc] && ::File.exist?("/etc/chef/client.pem")
  link "/etc/#{chef_name}/client.pem" do
    to "/etc/chef/client.pem"
    link_type :hard
    owner "root"
    group "root"
    mode "0400"
  end
else
  file "/etc/#{chef_name}/client.pem" do
    owner "root"
    group "root"
    mode "400"
  end
end

template "/etc/#{chef_name}/report.rb" do
  source "report.rb.erb"
  owner "root"
  group "root"
  mode "644"
end

package "logrotate"

template "/etc/logrotate.d/#{chef_name}" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode "644"
  variables :chef_name => chef_name
end

directory "/var/log/#{chef_name}" do
  owner "root"
  group "root"
  mode "755"
end

systemd_service "#{chef_name}-client" do
  description "Chef client"
  exec_start "/usr/bin/#{chef_name}-client"
  nice 10
end

systemd_timer "#{chef_name}-client" do
  description "Chef client"
  after "network.target"
  on_active_sec 60
  on_unit_inactive_sec 25 * 60
  randomized_delay_sec 10 * 60
end

service "#{chef_name}-client.timer" do
  action [:enable, :start]
end
