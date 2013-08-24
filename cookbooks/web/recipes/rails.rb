#
# Cookbook Name:: web
# Recipe:: rails
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

include_recipe "tools"
include_recipe "web::base"

include_recipe "apache"
include_recipe "git"

web_passwords = data_bag_item("web", "passwords")
db_passwords = data_bag_item("db", "passwords")

directory "#{node[:web][:base_directory]}/bin" do
  owner "root"
  group "root"
  mode 0755
end

template "#{node[:web][:base_directory]}/bin/ruby" do
  source "ruby.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :reload, "service[apache2]"
end

apache_module "passenger" do
  conf "passenger.conf.erb"
end

package "passenger-common#{node[:web][:ruby_version]}"

munin_plugin "passenger_memory"
munin_plugin "passenger_processes"
munin_plugin "passenger_queues"
munin_plugin "passenger_requests"

template "/etc/cron.hourly/passenger" do
  cookbook "web"
  source "passenger.cron.erb"
  owner "root"
  group "root"
  mode 0755
end

rails_directory = "#{node[:web][:base_directory]}/rails"

piwik_configuration = data_bag_item("web", "piwik").to_hash.reject do |k,v|
  ["chef_type", "data_bag", "id"].include?(k)
end

rails_port "www.openstreetmap.org" do
  ruby node[:web][:ruby_version]
  directory rails_directory
  user "rails"
  group "rails"
  repository "git://git.openstreetmap.org/rails.git"
  revision "live"
  database_host node[:web][:database_host]
  database_name "openstreetmap"
  database_username "rails"
  database_password db_passwords["rails"]
  email_from "OpenStreetMap <web@noreply.openstreetmap.org>"
  status node[:web][:status]
  messages_domain "messages.openstreetmap.org"
  quova_username "ws360602"
  quova_password web_passwords["quova"]
  soft_memory_limit node[:web][:rails_soft_memory_limit]
  hard_memory_limit node[:web][:rails_hard_memory_limit]
  gpx_dir "/store/rails/gpx"
  attachments_dir "/store/rails/attachments"
  log_path "#{node[:web][:log_directory]}/rails.log"
  memcache_servers [ "rails1", "rails2", "rails3" ]
  potlatch2_key web_passwords["potlatch2_key"]
  id_key web_passwords["id_key"]
  oauth_key web_passwords["oauth_key"]
  piwik_location "piwik.openstreetmap.org"
  piwik_site 1
  piwik_signup_goal 1
  piwik_configuration piwik_configuration
end
