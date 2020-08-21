#
# Cookbook:: geoipdate
# Recipe:: default
#
# Copyright:: 2020, OpenStreetMap Foundation
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

include_recipe "apt"

license_keys = data_bag_item("geoipupdate", "license-keys")

package "geoipupdate"

template "/etc/GeoIP.conf" do
  source "GeoIP.conf.erb"
  owner "root"
  group "root"
  mode "644"
  variables :license_keys => license_keys
end

execute "geoipupdate" do
  command "geoipupdate"
  user "root"
  group "root"
  not_if { ENV.key?("TEST_KITCHEN") || node[:geoipupdate][:editions].all? { |edition| ::File.exist?("/usr/share/GeoIP/#{edition}.mmdb") } }
end

systemd_service "geoipupdate" do
  description "Update GeoIP databases"
  user "root"
  exec_start "/usr/bin/geoipupdate"
  private_tmp true
  private_devices true
  protect_system "strict"
  protect_home true
  read_write_paths "/usr/share/GeoIP"
end

systemd_timer "geoipupdate" do
  description "Update GeoIP databases"
  on_boot_sec "15m"
  on_unit_active_sec "7d"
  randomized_delay_sec "4h"
end

service "geoipupdate.timer" do
  action [:enable, :start]
end
