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

cinc_version = node[:chef][:client][:version]

cinc_platform = if platform?("debian")
                  "debian"
                else
                  "ubuntu"
                end

cinc_arch = if arm?
              "arm64"
            else
              "amd64"
            end

os_release = node[:lsb][:release]

cinc_package = "cinc_#{cinc_version}-1_#{cinc_arch}.deb"

Dir.glob("#{cache_dir}/cinc_*.deb").each do |deb|
  next if deb == "#{cache_dir}/#{cinc_package}"

  file deb do
    action :delete
    backup false
  end
end

remote_file "#{cache_dir}/#{cinc_package}" do
  source "https://downloads.cinc.sh/files/stable/cinc/#{cinc_version}/#{cinc_platform}/#{os_release}/#{cinc_package}"
  owner "root"
  group "root"
  mode "644"
  backup false
  ignore_failure true
end

dpkg_package "cinc" do
  source "#{cache_dir}/#{cinc_package}"
  version "#{cinc_version}-1"
end

directory "/etc/cinc" do
  owner "root"
  group "root"
  mode "755"
end

template "/etc/cinc/client.rb" do
  source "client.rb.erb"
  owner "root"
  group "root"
  mode "640"
end

file "/etc/cinc/client.pem" do
  owner "root"
  group "root"
  mode "400"
end

template "/etc/cinc/report.rb" do
  source "report.rb.erb"
  owner "root"
  group "root"
  mode "644"
end

package "logrotate"

template "/etc/logrotate.d/cinc" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/var/log/cinc" do
  owner "root"
  group "root"
  mode "755"
end

systemd_service "cinc-client" do
  description "Cinc client"
  exec_start "/usr/bin/cinc-client"
  nice 10
end

systemd_timer "cinc-client" do
  description "Cinc client"
  after "network.target"
  on_active_sec 60
  on_unit_inactive_sec 25 * 60
  randomized_delay_sec 10 * 60
end

service "cinc-client.timer" do
  action [:enable, :start]
end
