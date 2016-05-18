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
include_recipe "passenger"
include_recipe "git"
include_recipe "nodejs"

web_passwords = data_bag_item("web", "passwords")
db_passwords = data_bag_item("db", "passwords")

nodejs_package "svgo"

template "/etc/cron.hourly/passenger" do
  cookbook "web"
  source "passenger.cron.erb"
  owner "root"
  group "root"
  mode 0755
end

rails_directory = "#{node[:web][:base_directory]}/rails"

piwik_configuration = data_bag_item("web", "piwik").to_hash.reject do |k, _|
  %w(chef_type data_bag id).include?(k)
end

rails_port "www.openstreetmap.org" do
  ruby node[:passenger][:ruby_version]
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
  gpx_dir "/store/rails/gpx"
  attachments_dir "/store/rails/attachments"
  log_path "#{node[:web][:log_directory]}/rails.log"
  logstash_path "#{node[:web][:log_directory]}/rails-logstash.log"
  memcache_servers node[:web][:memcached_servers]
  potlatch2_key web_passwords["potlatch2_key"]
  id_key web_passwords["id_key"]
  oauth_key web_passwords["oauth_key"]
  piwik_configuration piwik_configuration
  google_auth_id "651529786092-6c5ahcu0tpp95emiec8uibg11asmk34t.apps.googleusercontent.com"
  google_auth_secret web_passwords["google_auth_secret"]
  google_openid_realm "https://www.openstreetmap.org"
  facebook_auth_id "427915424036881"
  facebook_auth_secret web_passwords["facebook_auth_secret"]
  windowslive_auth_id "0000000040153C51"
  windowslive_auth_secret web_passwords["windowslive_auth_secret"]
  mapzen_valhalla_key web_passwords["mapzen_valhalla_key"]
end

package "libjson-xs-perl"

template "/usr/local/bin/cleanup-rails-assets" do
  source "cleanup-assets.erb"
  owner "root"
  group "root"
  mode 0755
end

gem_package "apachelogregex"
gem_package "file-tail"

template "/usr/local/bin/api-statistics" do
  source "api-statistics.erb"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/init.d/api-statistics" do
  source "api-statistics.init.erb"
  owner "root"
  group "root"
  mode 0755
end

service "api-statistics" do
  action [:enable, :start]
  supports :restart => true
  subscribes :restart, "template[/usr/local/bin/api-statistics]"
  subscribes :restart, "template[/etc/init.d/api-statistics]"
end

munin_plugin "api_calls_status"
munin_plugin "api_calls_num"

munin_plugin "api_calls_#{node[:hostname]}" do
  target "api_calls_"
end

munin_plugin "api_waits_#{node[:hostname]}" do
  target "api_waits_"
end
