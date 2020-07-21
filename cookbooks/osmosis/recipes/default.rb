#
# Cookbook:: osmosis
# Recipe:: default
#
# Copyright:: 2013, OpenStreetMap Foundation
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

include_recipe "chef"

package "unzip"
package "default-jre"

cache_dir = Chef::Config[:file_cache_path]

osmosis_version = node[:osmosis][:version]
osmosis_package = "osmosis-#{osmosis_version}.zip"
osmosis_directory = "/opt/osmosis-#{osmosis_version}"

Dir.glob("#{cache_dir}/osmosis-*.zip").each do |zip|
  next if zip == "#{cache_dir}/#{osmosis_package}"

  file zip do
    action :delete
    backup false
  end
end

directory osmosis_directory do
  owner "root"
  group "root"
  mode "755"
end

remote_file "#{cache_dir}/#{osmosis_package}" do
  action :create_if_missing
  source "https://github.com/openstreetmap/osmosis/releases/download/#{osmosis_version}/osmosis-#{osmosis_version}.zip"
  owner "root"
  group "root"
  mode "644"
  backup false
end

execute "#{cache_dir}/#{osmosis_package}" do
  action :nothing
  command "unzip -q #{cache_dir}/#{osmosis_package}"
  cwd osmosis_directory
  user "root"
  group "root"
  subscribes :run, "remote_file[#{cache_dir}/#{osmosis_package}]"
end

link "/usr/local/bin/osmosis" do
  to "#{osmosis_directory}/bin/osmosis"
end

link "/usr/local/bin/osmosis-extract-apidb-0.6" do
  to "#{osmosis_directory}/bin/osmosis-extract-apidb-0.6"
end
