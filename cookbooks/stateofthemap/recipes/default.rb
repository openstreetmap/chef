#
# Cookbook Name:: stateofthemap
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

include_recipe "wordpress"

passwords = data_bag_item("stateofthemap", "passwords")

directory "/srv/2007.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode 0755
end

wordpress_site "2007.stateofthemap.org" do
  aliases "2007.stateofthemap.com"
  directory "/srv/2007.stateofthemap.org/wp"
  database_name "sotm2007"
  database_user "sotm2007"
  database_password passwords["sotm2007"]
  database_prefix "wp_sotm_"
end

wordpress_theme "refreshwp-11" do
  site "2007.stateofthemap.org"
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "theme-2007"
end

wordpress_plugin "geopress" do
  site "2007.stateofthemap.org"
end

wordpress_plugin "sem-static-front" do
  site "2007.stateofthemap.org"
  repository "git://chef.openstreetmap.org/sem-static-front.git"
end

directory "/srv/2008.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode 0755
end

wordpress_site "2008.stateofthemap.org" do
  aliases "2008.stateofthemap.com"
  directory "/srv/2008.stateofthemap.org/wp"
  database_name "sotm2008"
  database_user "sotm2008"
  database_password passwords["sotm2008"]
  database_prefix "wp_sotm08_"
end

wordpress_theme "refreshwp-11" do
  site "2008.stateofthemap.org"
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "theme-2008"
end

wordpress_plugin "geopress" do
  site "2008.stateofthemap.org"
end

directory "/srv/2009.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode 0755
end

git "/srv/2009.stateofthemap.org" do
  action :sync
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "resources-2009"
  user "wordpress"
  group "wordpress"
end

wordpress_site "2009.stateofthemap.org" do
  aliases "2009.stateofthemap.com"
  directory "/srv/2009.stateofthemap.org/wp"
  database_name "sotm2009"
  database_user "sotm2009"
  database_password passwords["sotm2009"]
  urls "/register" => "/srv/2009.stateofthemap.org/register",
       "/register-pro-user" => "/srv/2009.stateofthemap.org/register-pro-user",
       "/podcasts" => "/srv/2009.stateofthemap.org/podcasts"
end

wordpress_theme "aerodrome" do
  site "2009.stateofthemap.org"
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "theme-2009"
end

wordpress_plugin "wp-sticky" do
  site "2009.stateofthemap.org"
end

directory "/srv/2010.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode 0755
end

git "/srv/2010.stateofthemap.org" do
  action :sync
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "resources-2010"
  user "wordpress"
  group "wordpress"
end

wordpress_site "2010.stateofthemap.org" do
  aliases "2010.stateofthemap.com"
  directory "/srv/2010.stateofthemap.org/wp"
  database_name "sotm2010"
  database_user "sotm2010"
  database_password passwords["sotm2010"]
  urls "/register" => "/srv/2010.stateofthemap.org/register"
end

wordpress_theme "aerodrome" do
  site "2010.stateofthemap.org"
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "theme-2010"
end

wordpress_plugin "sitepress-multilingual-cms" do
  site "2010.stateofthemap.org"
  source "plugins/sitepress-multilingual-cms"
end

wordpress_plugin "wp-sticky" do
  site "2010.stateofthemap.org"
end

directory "/srv/2011.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode 0755
end

git "/srv/2011.stateofthemap.org" do
  action :sync
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "resources-2011"
  user "wordpress"
  group "wordpress"
end

wordpress_site "2011.stateofthemap.org" do
  aliases "2011.stateofthemap.com"
  directory "/srv/2011.stateofthemap.org/wp"
  database_name "sotm2011"
  database_user "sotm2011"
  database_password passwords["sotm2011"]
  urls "/register" => "/srv/2011.stateofthemap.org/register"
end

wordpress_theme "aerodrome" do
  site "2011.stateofthemap.org"
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "theme-2011"
end

wordpress_plugin "sitepress-multilingual-cms" do
  site "2011.stateofthemap.org"
  source "plugins/sitepress-multilingual-cms"
end

wordpress_plugin "wp-sticky" do
  site "2011.stateofthemap.org"
end

directory "/srv/2012.stateofthemap.org" do
  owner "wordpress"
  group "wordpress"
  mode 0755
end

git "/srv/2012.stateofthemap.org" do
  action :sync
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "resources-2012"
  user "wordpress"
  group "wordpress"
end

wordpress_site "2012.stateofthemap.org" do
  aliases "2012.stateofthemap.com"
  directory "/srv/2012.stateofthemap.org/wp"
  database_name "sotm2012"
  database_user "sotm2012"
  database_password passwords["sotm2012"]
  urls "/register" => "/srv/2012.stateofthemap.org/register"
end

wordpress_theme "aerodrome" do
  site "2012.stateofthemap.org"
  repository "git://git.openstreetmap.org/stateofthemap.git"
  revision "theme-2012"
end

wordpress_plugin "leaflet-maps-marker" do
  site "2012.stateofthemap.org"
end

wordpress_plugin "sitepress-multilingual-cms" do
  site "2012.stateofthemap.org"
  source "plugins/sitepress-multilingual-cms"
end

wordpress_plugin "wp-sticky" do
  site "2012.stateofthemap.org"
end

template "/etc/cron.daily/sotm-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0750
  variables :passwords => passwords
end
