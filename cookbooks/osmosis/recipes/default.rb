#
# Cookbook Name:: osmosis
# Recipe:: default
#
# Copyright 2013, OpenStreetMap Foundation
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

include_recipe "chef"

package "unzip"
package "openjdk-6-jre"

osmosis_package = "osmosis-#{node[:osmosis][:version]}.zip"
osmosis_directory = "/opt/osmosis-#{node[:osmosis][:version]}"

Dir.glob("/var/cache/chef/osmosis-*.zip").each do |zip|
  if zip != "/var/cache/chef/#{osmosis_package}"
    file zip do
      action :delete
      backup false
    end
  end
end

directory osmosis_directory do
  owner "root"
  group "root"
  mode 0755
end

execute "/var/cache/chef/#{osmosis_package}" do
  action :nothing
  command "unzip -q /var/cache/chef/#{osmosis_package}"
  cwd osmosis_directory
  user "root"
  group "root"
end

remote_file "/var/cache/chef/#{osmosis_package}" do
  action :create_if_missing
  source "http://bretth.dev.openstreetmap.org/osmosis-build/#{osmosis_package}"
  owner "root"
  group "root"
  mode 0644
  backup false
  notifies :run, "execute[/var/cache/chef/#{osmosis_package}]"
end

link "/usr/local/bin/osmosis" do
  to "#{osmosis_directory}/bin/osmosis"
end

link "/usr/local/bin/osmosis-extract-apidb-0.6" do
  to "#{osmosis_directory}/bin/osmosis-extract-apidb-0.6"
end
