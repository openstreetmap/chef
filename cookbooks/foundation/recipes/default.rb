#
# Cookbook Name:: foundation
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

passwords = data_bag_item("foundation", "passwords")

wordpress_site "blog.osmfoundation.org" do
  database_name "osmf-blog"
  database_user "osmf-blog-user"
  database_password passwords["osmf-blog-user"]
end

wordpress_theme "osmf-blog-theme" do
  site "blog.osmfoundation.org"
  repository "http://svn.openstreetmap.org/extensions/wordpress/osmf-blog-theme"
end

wordpress_plugin "google-analytics-for-wordpress" do
  site "blog.osmfoundation.org"
end

wordpress_plugin "google-sitemap-generator" do
  site "blog.osmfoundation.org"
end

wordpress_plugin "shareadraft" do
  site "blog.osmfoundation.org"
end

wordpress_plugin "sitepress-multilingual-cms" do
  site "blog.osmfoundation.org"
  source "plugins/sitepress-multilingual-cms"
end

template "/etc/cron.daily/blog-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0750
  variable :passwords => passwords
end
