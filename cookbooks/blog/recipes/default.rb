#
# Cookbook:: blog
# Recipe:: default
#
# Copyright:: 2013, OpenStreetMap Foundation
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

include_recipe "wordpress"

passwords = data_bag_item("blog", "passwords")
wp2fa_encrypt_keys = data_bag_item("blog", "wp2fa_encrypt_keys")

directory "/srv/blog.openstreetmap.org" do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

wordpress_site "blog.openstreetmap.org" do
  aliases ["blog.osm.org", "blog.openstreetmap.com",
           "blog.openstreetmap.net", "blog.openstreetmaps.org",
           "blog.osmfoundation.org",
           "opengeodata.org", "www.opengeodata.org",
           "old.opengeodata.org" # https://blog.openstreetmap.org/2010/02/25/old-opengeodata-posts-now-up-at-old-opengeodata-org/
          ]
  directory "/srv/blog.openstreetmap.org/wp"
  database_name "osm-blog"
  database_user "osm-blog-user"
  database_password passwords["osm-blog-user"]
  wp2fa_encrypt_key wp2fa_encrypt_keys["key"]
  urls "/casts" => "/srv/blog.openstreetmap.org/casts",
       "/images" => "/srv/blog.openstreetmap.org/images",
       "/static" => "/srv/blog.openstreetmap.org/static"
  fpm_prometheus_port 11401
end

wordpress_theme "blog.openstreetmap.org-osmblog-wp-theme" do
  theme "osmblog-wp-theme"
  site "blog.openstreetmap.org"
  repository "https://github.com/osmfoundation/osmblog-wp-theme.git"
end

wordpress_plugin "blog.openstreetmap.org-google-analytics-for-wordpress" do
  action :delete
  plugin "google-analytics-for-wordpress"
  site "blog.openstreetmap.org"
end

wordpress_plugin "blog.openstreetmap.org-google-sitemap-generator" do
  action :delete
  plugin "google-sitemap-generator"
  site "blog.openstreetmap.org"
end

# wordpress_plugin "blog.openstreetmap.org-www-xml-sitemap-generator-org" do
#   plugin "www-xml-sitemap-generator-org"
#   site "blog.openstreetmap.org"
# end

wordpress_plugin "blog.openstreetmap.org-shareadraft" do
  action :delete
  plugin "shareadraft"
  site "blog.openstreetmap.org"
end

wordpress_plugin "blog.openstreetmap.org-public-post-preview" do
  plugin "public-post-preview"
  site "blog.openstreetmap.org"
end

wordpress_plugin "blog.openstreetmap.org-sitepress-multilingual-cms" do
  plugin "sitepress-multilingual-cms"
  site "blog.openstreetmap.org"
  repository "https://git.openstreetmap.org/private/sitepress-multilingual-cms.git"
  revision "master"
  not_if { kitchen? }
end

wordpress_plugin "blog.openstreetmap.org-wordpress-importer" do
  action :delete
  plugin "wordpress-importer"
  site "blog.openstreetmap.org"
end

wordpress_plugin "blog.openstreetmap.org-wp-piwik" do
  plugin "wp-piwik"
  site "blog.openstreetmap.org"
end

git "/srv/blog.openstreetmap.org/casts" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-podcasts.git"
  revision "master"
  depth 1
  user "wordpress"
  group "wordpress"
end

git "/srv/blog.openstreetmap.org/images" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-images.git"
  revision "master"
  depth 1
  user "wordpress"
  group "wordpress"
end

git "/srv/blog.openstreetmap.org/static" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-static.git"
  revision "master"
  depth 1
  user "wordpress"
  group "wordpress"
end

template "/etc/cron.daily/blog-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "750"
  variables :passwords => passwords
end
