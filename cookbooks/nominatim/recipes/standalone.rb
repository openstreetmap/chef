#
# Cookbook Name:: nominatim
# Recipe:: standalone
#
# Copyright 2015, OpenStreetMap Foundation
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

include_recipe "git"

database_cluster = node[:nominatim][:database][:cluster]
home_directory = data_bag_item("accounts", "nominatim")["home"]

git "#{home_directory}/nominatim" do
  action :checkout
  repository node[:nominatim][:repository]
  revision node[:nominatim][:revision]
  enable_submodules true
  user "nominatim"
  group "nominatim"
  notifies :run, "execute[compile_nominatim]"
end

include_recipe "nominatim::base"

superusers = %w(tomh lonvia twain nominatim)

superusers.each do |user|
  postgresql_user user do
    cluster database_cluster
    superuser true
  end
end

postgresql_user "www-data" do
  cluster database_cluster
end
