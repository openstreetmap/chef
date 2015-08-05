#
# Cookbook Name:: web
# Recipe:: gpx
#
# Copyright 2011, OpenStreetMap Foundation
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

include_recipe "web::base"

db_passwords = data_bag_item("db", "passwords")

gpx_import "gpx-import" do
  revision "live"
  directory "#{node[:web][:base_directory]}/gpx-import"
  user "rails"
  group "rails"
  pid_directory node[:web][:pid_directory]
  log_directory node[:web][:log_directory]
  database_host node[:web][:database_host]
  database_name "openstreetmap"
  database_username "gpximport"
  database_password db_passwords["gpximport"]
  store_directory "/store/rails/gpx"
  memcache_servers %w(rails1 rails2 rails3)
  status node[:web][:status]
end
