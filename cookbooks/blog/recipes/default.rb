#
# Cookbook Name:: blog
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

node.default[:ssl][:certificates] = node[:ssl][:certificates] | ["osmfoundation"]

include_recipe "wordpress"

passwords = data_bag_item("blog", "passwords")

directory "/srv/blog.openstreetmap.org" do
  owner "wordpress"
  group "wordpress"
  mode 0o755
end

wordpress_site "blog.openstreetmap.org" do
  aliases ["blog.osm.org", "blog.openstreetmap.com",
           "blog.openstreetmap.net", "blog.openstreetmaps.org",
           "blog.osmfoundation.org"]
  ssl_enabled true
  ssl_certificate "osmfoundation"
  ssl_certificate_chain "startcom"
  directory "/srv/blog.openstreetmap.org/wp"
  database_name "osm-blog"
  database_user "osm-blog-user"
  database_password passwords["osm-blog-user"]
  urls "/casts" => "/srv/blog.openstreetmap.org/casts",
       "/images" => "/srv/blog.openstreetmap.org/images",
       "/news" => "/srv/blog.openstreetmap.org/news"
end

wordpress_theme "osmblog-wp-theme" do
  site "blog.openstreetmap.org"
  repository "git://github.com/harry-wood/osmblog-wp-theme.git"
end

wordpress_plugin "google-analytics-for-wordpress" do
  site "blog.openstreetmap.org"
end

wordpress_plugin "google-sitemap-generator" do
  site "blog.openstreetmap.org"
end

wordpress_plugin "shareadraft" do
  site "blog.openstreetmap.org"
end

wordpress_plugin "sitepress-multilingual-cms" do
  site "blog.openstreetmap.org"
  repository "git://chef.openstreetmap.org/sitepress-multilingual-cms.git"
end

wordpress_plugin "wordpress-importer" do
  site "blog.openstreetmap.org"
end

git "/srv/blog.openstreetmap.org/casts" do
  action :sync
  repository "git://github.com/openstreetmap/opengeodata-podcasts.git"
  depth 1
  user "wordpress"
  group "wordpress"
end

git "/srv/blog.openstreetmap.org/images" do
  action :sync
  repository "git://github.com/openstreetmap/opengeodata-images.git"
  depth 1
  user "wordpress"
  group "wordpress"
end

apache_site "opengeodata.org" do
  template "opengeodata.erb"
  directory "/srv/opengeodata.org"
end

template "/etc/cron.daily/blog-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0o750
  variables :passwords => passwords
end
