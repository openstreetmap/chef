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
include_recipe "nodejs"
include_recipe "passenger"
include_recipe "ruby"
include_recipe "tools"
include_recipe "web::base"

web_passwords = data_bag_item("web", "passwords")
db_passwords = data_bag_item("db", "passwords")

ssl_certificate "www.openstreetmap.org" do
  domains ["www.openstreetmap.org", "www.osm.org", "www.openstreetmap.com",
           "api.openstreetmap.org", "api.osm.org",
           "maps.openstreetmap.org", "maps.osm.org",
           "mapz.openstreetmap.org", "mapz.osm.org",
           "openstreetmap.org", "osm.org", "openstreetmap.com"]
  notifies :reload, "service[apache2]"
end

nodejs_package "svgo"

rails_directory = "#{node[:web][:base_directory]}/rails"

matomo = data_bag_item("web", "matomo")

storage = {
  "avatars" => {
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
  },
  "gps_traces" => {
    "service" => "S3",
    "access_key_id" => "AKIASQUXHPE7AMJQRFOS",
    "secret_access_key" => web_passwords["aws_key"],
    "region" => "eu-west-1",
    "bucket" => "openstreetmap-gps-traces",
    "use_dualstack_endpoint" => true,
    "upload" => {
      "acl" => "public-read",
      "cache_control" => "public, max-age=31536000, immutable"
    }
  },
  "gps_images" => {
    "service" => "S3",
    "access_key_id" => "AKIASQUXHPE7AMJQRFOS",
    "secret_access_key" => web_passwords["aws_key"],
    "region" => "eu-west-1",
    "bucket" => "openstreetmap-gps-images",
    "use_dualstack_endpoint" => true,
    "upload" => {
      "acl" => "public-read",
      "cache_control" => "public, max-age=31536000, immutable"
    }
  }
}

db_host = if node[:web][:status] == "database_readonly"
            node[:web][:readonly_database_host]
          else
            node[:web][:database_host]
          end

rails_port "www.openstreetmap.org" do
  directory rails_directory
  user "rails"
  group "rails"
  repository "https://git.openstreetmap.org/public/rails.git"
  revision "live"
  database_host db_host
  database_name "openstreetmap"
  database_username "rails"
  database_password db_passwords["rails"]
  email_from "OpenStreetMap <web@noreply.openstreetmap.org>"
  status node[:web][:status]
  messages_domain "messages.openstreetmap.org"
  log_path "#{node[:web][:log_directory]}/rails.log"
  logstash_path "#{node[:web][:log_directory]}/rails-logstash.log"
  memcache_servers node[:web][:memcached_servers]
  potlatch2_key web_passwords["potlatch2_key"]
  id_key web_passwords["id_key"]
  id_application web_passwords["id_application"]
  oauth_key web_passwords["oauth_key"]
  oauth_application web_passwords["oauth_application"]
  matomo_configuration "location" => matomo[:location],
                       "site" => matomo[:site],
                       "visitor_cookie_timeout" => matomo[:visitor_cookie_timeout],
                       "referral_cookie_timeout" => matomo[:referral_cookie_timeout],
                       "session_cookie_timeout" => matomo[:session_cookie_timeout],
                       "goals" => matomo[:goals].to_hash
  google_auth_id "651529786092-6c5ahcu0tpp95emiec8uibg11asmk34t.apps.googleusercontent.com"
  google_auth_secret web_passwords["google_auth_secret"]
  google_openid_realm "https://www.openstreetmap.org"
  facebook_auth_id "427915424036881"
  facebook_auth_secret web_passwords["facebook_auth_secret"]
  microsoft_auth_id "e34f14f1-f790-40f3-9fa4-3c5f1a027c38"
  microsoft_auth_secret web_passwords["microsoft_auth_secret"]
  github_auth_id "acf7da34edee99e35499"
  github_auth_secret web_passwords["github_auth_secret"]
  wikipedia_auth_id "e4fe0c2c5855d23ed7e1f1c0fa1f1c58"
  wikipedia_auth_secret web_passwords["wikipedia_auth_secret"]
  thunderforest_key web_passwords["thunderforest_key"]
  tracestrack_key web_passwords["tracestrack_key"]
  totp_key web_passwords["totp_key"]
  csp_enforce true
  trace_use_job_queue true
  diary_feed_delay 12
  storage_configuration storage
  avatar_storage "avatars"
  trace_file_storage "gps_traces"
  trace_image_storage "gps_images"
  trace_icon_storage "gps_images"
  avatar_storage_url "https://openstreetmap-user-avatars.s3.dualstack.eu-west-1.amazonaws.com"
  trace_image_storage_url "https://openstreetmap-gps-images.s3.dualstack.eu-west-1.amazonaws.com"
  overpass_url "https://query.openstreetmap.org/query-features"
  overpass_credentials true
  signup_ip_per_day 24
  signup_ip_max_burst 48
  signup_email_per_day 1
  signup_email_max_burst 2
  doorkeeper_signing_key web_passwords["openid_connect_key"].join("\n")
  user_account_deletion_delay 7 * 24
  # Requests to modify the imagery blacklist should come from the DWG only
  imagery_blacklist [
    # Current Google imagery URLs have google or googleapis in the domain
    ".*\\.google(apis)?\\..*/.*",
    # Blacklist VWorld
    "http://xdworld\\.vworld\\.kr:8080/.*",
    # Blacklist here
    ".*\\.here\\.com[/:].*",
    # Blacklist Mapy.cz
    ".*\\.mapy\\.cz.*",
    # Blacklist Yandex
    ".*\\.api-maps\\.yandex\\.ru/.*",
    ".*\\.maps\\.yandex\\.net/.*"
  ]
end

systemd_service "rails-jobs@" do
  description "Rails job queue runner"
  type "simple"
  environment "RAILS_ENV" => "production",
              "QUEUE" => "%I",
              "SLEEP_DELAY" => "60",
              "SECRET_KEY_BASE" => web_passwords["secret_key_base"]
  user "rails"
  working_directory rails_directory
  exec_start "#{node[:ruby][:bundle]} exec rails jobs:work"
  restart "on-failure"
  nice 10
  sandbox :enable_network => true
  memory_deny_write_execute false
  read_write_paths "/var/log/web"
end

package "libjson-xs-perl"

template "/usr/local/bin/cleanup-rails-assets" do
  source "cleanup-assets.erb"
  owner "root"
  group "root"
  mode "755"
end

gem_package "apachelogregex" do
  gem_binary node[:ruby][:gem]
end

gem_package "file-tail" do
  gem_binary node[:ruby][:gem]
end

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
  nice 10
  sandbox true
  read_write_paths [
    "/srv/www.openstreetmap.org/rails/tmp",
    "/var/lib/prometheus/node-exporter"
  ]
  restart "on-failure"
end

service "api-statistics" do
  action [:enable, :start]
  supports :restart => true
  subscribes :restart, "template[/usr/local/bin/api-statistics]"
  subscribes :restart, "systemd_service[api-statistics]"
end

gem_package "hpricot" do
  gem_binary node[:ruby][:gem]
end
