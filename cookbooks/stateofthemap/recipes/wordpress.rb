#
# Cookbook:: stateofthemap
# Recipe:: wordpress
#
# Copyright:: 2022, OpenStreetMap Foundation
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

include_recipe "stateofthemap"
include_recipe "wordpress"

passwords = data_bag_item("stateofthemap", "passwords")
wp2fa_encrypt_keys = data_bag_item("stateofthemap", "wp2fa_encrypt_keys")

directory "/srv/2010.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

git "/srv/2010.stateofthemap.org" do
  action :sync
  repository "https://git.openstreetmap.org/public/stateofthemap.git"
  revision "resources-2010"
  depth 1
  user "wordpress"
  group "wordpress"
end

wordpress_site "2010.stateofthemap.org" do
  aliases ["2010.stateofthemap.com", "2010.sotm.org"]
  directory "/srv/2010.stateofthemap.org/wp"
  database_name "sotm2010"
  database_user "sotm2010"
  database_password passwords["sotm2010"]
  wp2fa_encrypt_key wp2fa_encrypt_keys["sotm2010"]
  urls "/register" => "/srv/2010.stateofthemap.org/register"
  fpm_prometheus_port 12010
end

wordpress_theme "2010.stateofthemap.org-aerodrome" do
  theme "aerodrome"
  site "2010.stateofthemap.org"
  repository "https://git.openstreetmap.org/public/stateofthemap.git"
  revision "theme-2010"
end

wordpress_plugin "2010.stateofthemap.org-sitepress-multilingual-cms" do
  plugin "sitepress-multilingual-cms"
  site "2010.stateofthemap.org"
  repository "https://git.openstreetmap.org/private/sitepress-multilingual-cms.git"
  revision "master"
  not_if { kitchen? }
end

# wordpress_plugin "2010.stateofthemap.org-wp-sticky" do
#   plugin "wp-sticky"
#   site "2010.stateofthemap.org"
# end

directory "/srv/2011.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

git "/srv/2011.stateofthemap.org" do
  action :sync
  repository "https://git.openstreetmap.org/public/stateofthemap.git"
  revision "resources-2011"
  depth 1
  user "wordpress"
  group "wordpress"
end

wordpress_site "2011.stateofthemap.org" do
  aliases ["2011.stateofthemap.com", "2011.sotm.org"]
  directory "/srv/2011.stateofthemap.org/wp"
  database_name "sotm2011"
  database_user "sotm2011"
  database_password passwords["sotm2011"]
  wp2fa_encrypt_key wp2fa_encrypt_keys["sotm2011"]
  urls "/register" => "/srv/2011.stateofthemap.org/register"
  fpm_prometheus_port 12011
end

wordpress_theme "2011.stateofthemap.org-aerodrome" do
  theme "aerodrome"
  site "2011.stateofthemap.org"
  repository "https://git.openstreetmap.org/public/stateofthemap.git"
  revision "theme-2011"
end

wordpress_plugin "2011.stateofthemap.org-sitepress-multilingual-cms" do
  plugin "sitepress-multilingual-cms"
  site "2011.stateofthemap.org"
  repository "https://git.openstreetmap.org/private/sitepress-multilingual-cms.git"
  revision "master"
  not_if { kitchen? }
end

# wordpress_plugin "2011.stateofthemap.org-wp-sticky" do
#   plugin "wp-sticky"
#   site "2011.stateofthemap.org"
# end

directory "/srv/2012.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

git "/srv/2012.stateofthemap.org" do
  action :sync
  repository "https://git.openstreetmap.org/public/stateofthemap.git"
  revision "resources-2012"
  depth 1
  user "wordpress"
  group "wordpress"
end

wordpress_site "2012.stateofthemap.org" do
  aliases ["2012.stateofthemap.com", "2012.sotm.org"]
  directory "/srv/2012.stateofthemap.org/wp"
  database_name "sotm2012"
  database_user "sotm2012"
  database_password passwords["sotm2012"]
  wp2fa_encrypt_key wp2fa_encrypt_keys["sotm2012"]
  urls "/register" => "/srv/2012.stateofthemap.org/register"
  fpm_prometheus_port 12012
end

wordpress_theme "2012.stateofthemap.org-aerodrome" do
  theme "aerodrome"
  site "2012.stateofthemap.org"
  repository "https://git.openstreetmap.org/public/stateofthemap.git"
  revision "theme-2012"
end

wordpress_plugin "2012.stateofthemap.org-leaflet-maps-marker" do
  plugin "leaflet-maps-marker"
  site "2012.stateofthemap.org"
end

wordpress_plugin "2012.stateofthemap.org-sitepress-multilingual-cms" do
  plugin "sitepress-multilingual-cms"
  site "2012.stateofthemap.org"
  repository "https://git.openstreetmap.org/private/sitepress-multilingual-cms.git"
  revision "master"
  not_if { kitchen? }
end

# wordpress_plugin "2012.stateofthemap.org-wp-sticky" do
#   plugin "wp-sticky"
#   site "2012.stateofthemap.org"
# end

template "/etc/cron.daily/sotm-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "750"
  variables :passwords => passwords
end
