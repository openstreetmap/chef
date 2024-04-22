#
# Cookbook:: blog
# Recipe:: staging
#
# Copyright:: 2024, OpenStreetMap Foundation
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

passwords = data_bag_item("blog-staging", "passwords")
wp2fa_encrypt_keys = data_bag_item("blog-staging", "wp2fa_encrypt_keys")

directory "/srv/staging.blog.openstreetmap.org" do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

wordpress_site "staging.blog.openstreetmap.org" do
  aliases ["staging.blog.osm.org", "staging.blog.openstreetmap.com",
           "staging.blog.openstreetmap.net", "staging.blog.openstreetmaps.org",
           "staging.blog.osmfoundation.org"
          ]
  directory "/srv/staging.blog.openstreetmap.org/wp"
  database_name "osm-blog-staging"
  database_user "osm-blog-staging-user"
  database_password passwords["osm-blog-staging-user"]
  wp2fa_encrypt_key wp2fa_encrypt_keys["key"]
  urls "/casts" => "/srv/staging.blog.openstreetmap.org/casts",
       "/images" => "/srv/staging.blog.openstreetmap.org/images",
       "/static" => "/srv/staging.blog.openstreetmap.org/static"
  fpm_prometheus_port 11401
end

wordpress_theme "staging.blog.openstreetmap.org-osmblog-wp-theme" do
  theme "osmblog-wp-theme"
  site "staging.blog.openstreetmap.org"
  repository "https://github.com/osmfoundation/osmblog-wp-theme.git"
end

wordpress_plugin "staging.blog.openstreetmap.org-google-analytics-for-wordpress" do
  action :delete
  plugin "google-analytics-for-wordpress"
  site "staging.blog.openstreetmap.org"
end

wordpress_plugin "staging.blog.openstreetmap.org-google-sitemap-generator" do
  action :delete
  plugin "google-sitemap-generator"
  site "staging.blog.openstreetmap.org"
end

# wordpress_plugin "blog.openstreetmap.org-www-xml-sitemap-generator-org" do
#   plugin "www-xml-sitemap-generator-org"
#   site "staging.blog.openstreetmap.org"
# end

wordpress_plugin "staging.blog.openstreetmap.org-shareadraft" do
  action :delete
  plugin "shareadraft"
  site "staging.blog.openstreetmap.org"
end

wordpress_plugin "staging.blog.openstreetmap.org-public-post-preview" do
  plugin "public-post-preview"
  site "staging.blog.openstreetmap.org"
end

wordpress_plugin "staging.blog.openstreetmap.org-sitepress-multilingual-cms" do
  plugin "sitepress-multilingual-cms"
  site "staging.blog.openstreetmap.org"
  repository "https://git.openstreetmap.org/private/sitepress-multilingual-cms.git"
  revision "master"
  not_if { kitchen? }
end

wordpress_plugin "staging.blog.openstreetmap.org-wordpress-importer" do
  action :delete
  plugin "wordpress-importer"
  site "staging.blog.openstreetmap.org"
end

wordpress_plugin "staging.blog.openstreetmap.org-wp-piwik" do
  plugin "wp-piwik"
  site "staging.blog.openstreetmap.org"
end

git "/srv/staging.blog.openstreetmap.org/casts" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-podcasts.git"
  revision "master"
  depth 1
  user "wordpress"
  group "wordpress"
end

git "/srv/staging.blog.openstreetmap.org/images" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-images.git"
  revision "master"
  depth 1
  user "wordpress"
  group "wordpress"
end

git "/srv/staging.blog.openstreetmap.org/static" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-static.git"
  revision "master"
  depth 1
  user "wordpress"
  group "wordpress"
end

template "/etc/cron.daily/blog-staging-backup" do
  source "backup-staging.cron.erb"
  owner "root"
  group "root"
  mode "750"
  variables :passwords => passwords
end
