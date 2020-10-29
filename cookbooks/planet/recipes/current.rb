#
# Cookbook:: planet
# Recipe:: current
#
# Copyright:: 2018, OpenStreetMap Foundation
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

include_recipe "accounts"

package %w[
  pyosmium
]

template "/usr/local/bin/planet-update" do
  source "planet-update.erb"
  owner "root"
  group "root"
  mode "755"
end

template "/usr/local/bin/planet-update-file" do
  source "planet-update-file.erb"
  owner "root"
  group "root"
  mode "755"
end

directory "/var/lib/planet" do
  owner "planet"
  group "planet"
  mode "755"
end

remote_file "/var/lib/planet/planet.osh.pbf" do
  action :create_if_missing
  source "https://planet.openstreetmap.org/pbf/full-history/history-latest.osm.pbf"
  owner "planet"
  group "planet"
  mode "644"
  not_if { ENV["TEST_KITCHEN"] }
end

cron_d "planet-update" do
  minute "17"
  hour "1"
  user "root"
  command "/usr/local/bin/planet-update"
end

template "/etc/logrotate.d/planet-update" do
  source "planet-update.logrotate.erb"
  owner "root"
  group "root"
  mode "644"
end
