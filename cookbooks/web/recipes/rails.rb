#
# Cookbook:: web
# Recipe:: rails
#
# Copyright:: 2011, OpenStreetMap Foundation
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

include_recipe "apache"
include_recipe "apt"
include_recipe "git"
include_recipe "geoipupdate"
include_recipe "munin"
include_recipe "nodejs"
include_recipe "passenger"
include_recipe "tools"
include_recipe "web::base"

web_passwords = data_bag_item("web", "passwords")
db_passwords = data_bag_item("db", "passwords")

ssl_certificate "www.openstreetmap.org" do
  domains ["www.openstreetmap.org", "www.osm.org",
           "api.openstreetmap.org", "api.osm.org",
           "maps.openstreetmap.org", "maps.osm.org",
           "mapz.openstreetmap.org", "mapz.osm.org",
           "openstreetmap.org", "osm.org"]
  notifies :reload, "service[apache2]"
end

nodejs_package "svgo"

template "/etc/cron.hourly/passenger" do
  cookbook "web"
  source "passenger.cron.erb"
  owner "root"
  group "root"
  mode "755"
end

ruby_version = node[:passenger][:ruby_version]
rails_directory = "#{node[:web][:base_directory]}/rails"

piwik = data_bag_item("web", "piwik")

storage = {
  "aws" => {
    "service" => "S3",
    "access_key_id" => "AKIASQUXHPE7AMJQRFOS",
    "secret_access_key" => web_passwords["aws_key"],
    "region" => "eu-west-1",
    "bucket" => "openstreetmap-user-avatars",
    "use_dualstack_endpoint" => true,
    "upload" => {
      "acl" => "public-read",
      "cache_control" => "public, max-age=31536000, immutable"
    }
  }
}

rails_port "www.openstreetmap.org" do
  ruby ruby_version
  directory rails_directory
  user "rails"
  group "rails"
  repository "https://git.openstreetmap.org/public/rails.git"
  revision "live"
  database_host node[:web][:database_host]
  database_name "openstreetmap"
  database_username "rails"
  database_password db_passwords["rails"]
  email_from "OpenStreetMap <web@noreply.openstreetmap.org>"
  status node[:web][:status]
  messages_domain "messages.openstreetmap.org"
  gpx_dir "/store/rails/gpx"
  attachments_dir "/store/rails/attachments"
  log_path "#{node[:web][:log_directory]}/rails.log"
  logstash_path "#{node[:web][:log_directory]}/rails-logstash.log"
  memcache_servers node[:web][:memcached_servers]
  potlatch2_key web_passwords["potlatch2_key"]
  id_key web_passwords["id_key"]
  oauth_key web_passwords["oauth_key"]
  piwik_configuration "location" => piwik[:location],
                      "site" => piwik[:site],
                      "goals" => piwik[:goals].to_hash
  google_auth_id "651529786092-6c5ahcu0tpp95emiec8uibg11asmk34t.apps.googleusercontent.com"
  google_auth_secret web_passwords["google_auth_secret"]
  google_openid_realm "https://www.openstreetmap.org"
  facebook_auth_id "427915424036881"
  facebook_auth_secret web_passwords["facebook_auth_secret"]
  windowslive_auth_id "0000000040153C51"
  windowslive_auth_secret web_passwords["windowslive_auth_secret"]
  github_auth_id "acf7da34edee99e35499"
  github_auth_secret web_passwords["github_auth_secret"]
  wikipedia_auth_id "e4fe0c2c5855d23ed7e1f1c0fa1f1c58"
  wikipedia_auth_secret web_passwords["wikipedia_auth_secret"]
  thunderforest_key web_passwords["thunderforest_key"]
  totp_key web_passwords["totp_key"]
  csp_enforce true
  trace_use_job_queue true
  diary_feed_delay 12
  storage_configuration storage
  storage_service "aws"
  storage_url "https://openstreetmap-user-avatars.s3.dualstack.eu-west-1.amazonaws.com"
  tile_cdn_url "https://cdn-fastly-test.tile.openstreetmap.org/{z}/{x}/{y}.png"
end

gem_package "bundler#{ruby_version}" do
  package_name "bundler"
  gem_binary "gem#{ruby_version}"
  options "--format-executable"
end

bundle = if File.exist?("/usr/bin/bundle#{ruby_version}")
           "/usr/bin/bundle#{ruby_version}"
         else
           "/usr/local/bin/bundle#{ruby_version}"
         end

systemd_service "rails-jobs@" do
  description "Rails job queue runner"
  type "simple"
  environment "RAILS_ENV" => "production", "QUEUE" => "%I"
  user "rails"
  working_directory rails_directory
  exec_start "#{bundle} exec rake jobs:work"
  restart "on-failure"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  no_new_privileges true
end

package "libjson-xs-perl"

template "/usr/local/bin/cleanup-rails-assets" do
  source "cleanup-assets.erb"
  owner "root"
  group "root"
  mode "755"
end

gem_package "apachelogregex"
gem_package "file-tail"

template "/usr/local/bin/api-statistics" do
  source "api-statistics.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "api-statistics" do
  description "OpenStreetMap API Statistics Daemon"
  user "rails"
  group "adm"
  exec_start "/usr/local/bin/api-statistics"
  private_tmp true
  private_devices true
  private_network true
  protect_system "full"
  protect_home true
  no_new_privileges true
  restart "on-failure"
end

service "api-statistics" do
  action [:enable, :start]
  supports :restart => true
  subscribes :restart, "template[/usr/local/bin/api-statistics]"
  subscribes :restart, "systemd_service[api-statistics]"
end

gem_package "hpricot"

munin_plugin "api_calls_status"
munin_plugin "api_calls_num"

munin_plugin "api_calls_#{node[:hostname]}" do
  target "api_calls_"
end

munin_plugin "api_waits_#{node[:hostname]}" do
  target "api_waits_"
end
