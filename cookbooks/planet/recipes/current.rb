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

package %w[
  pyosmium
]

template "/usr/local/bin/planet-update" do
  source "planet-update.erb"
  owner "root"
  group "root"
  mode 0o755
end

template "/usr/local/bin/planet-update-file" do
  source "planet-update-file.erb"
  owner "root"
  group "root"
  mode 0o755
end

directory "/var/lib/planet" do
  owner "planet"
  group "planet"
  mode 0o755
end

remote_file "/var/lib/planet/planet.pbf" do
  action :create_if_missing
  source "https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf"
  owner "planet"
  group "planet"
  mode 0o644
end

template "/etc/cron.d/planet-update" do
  source "planet-update.cron.erb"
  owner "root"
  group "root"
  mode 0o644
end

template "/etc/logrotate.d/planet-update" do
  source "planet-update.logrotate.erb"
  owner "root"
  group "root"
  mode 0o644
end
