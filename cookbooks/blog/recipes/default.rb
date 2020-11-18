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

directory "/srv/blog.openstreetmap.org" do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

wordpress_site "blog.openstreetmap.org" do
  aliases ["blog.osm.org", "blog.openstreetmap.com",
           "blog.openstreetmap.net", "blog.openstreetmaps.org",
           "blog.osmfoundation.org"]
  directory "/srv/blog.openstreetmap.org/wp"
  database_name "osm-blog"
  database_user "osm-blog-user"
  database_password passwords["osm-blog-user"]
  urls "/casts" => "/srv/blog.openstreetmap.org/casts",
       "/images" => "/srv/blog.openstreetmap.org/images",
       "/static" => "/srv/blog.openstreetmap.org/static"
  fpm_prometheus_port 11401
end

wordpress_theme "blog.openstreetmap.org-osmblog-wp-theme" do
  theme "osmblog-wp-theme"
  site "blog.openstreetmap.org"
  repository "https://github.com/harry-wood/osmblog-wp-theme.git"
end

wordpress_plugin "blog.openstreetmap.org-google-analytics-for-wordpress" do
  plugin "google-analytics-for-wordpress"
  site "blog.openstreetmap.org"
end

wordpress_plugin "blog.openstreetmap.org-google-sitemap-generator" do
  plugin "google-sitemap-generator"
  site "blog.openstreetmap.org"
end

wordpress_plugin "blog.openstreetmap.org-shareadraft" do
  plugin "shareadraft"
  site "blog.openstreetmap.org"
end

wordpress_plugin "blog.openstreetmap.org-sitepress-multilingual-cms" do
  plugin "sitepress-multilingual-cms"
  site "blog.openstreetmap.org"
  repository "https://git.openstreetmap.org/private/sitepress-multilingual-cms.git"
  not_if { ENV["TEST_KITCHEN"] }
end

wordpress_plugin "blog.openstreetmap.org-wordpress-importer" do
  plugin "wordpress-importer"
  site "blog.openstreetmap.org"
end

git "/srv/blog.openstreetmap.org/casts" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-podcasts.git"
  depth 1
  user "wordpress"
  group "wordpress"
end

git "/srv/blog.openstreetmap.org/images" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-images.git"
  depth 1
  user "wordpress"
  group "wordpress"
end

git "/srv/blog.openstreetmap.org/static" do
  action :sync
  repository "https://github.com/openstreetmap/opengeodata-static.git"
  depth 1
  user "wordpress"
  group "wordpress"
end

ssl_certificate "opengeodata.org" do
  domains ["opengeodata.org", "www.opengeodata.org", "old.opengeodata.org"]
  notifies :reload, "service[apache2]"
end

apache_site "opengeodata.org" do
  template "opengeodata.erb"
  directory "/srv/opengeodata.org"
end

template "/etc/cron.daily/blog-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "750"
  variables :passwords => passwords
end
