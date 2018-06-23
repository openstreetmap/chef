#
# Cookbook Name:: switch2osm
# Recipe:: default
#
# Copyright 2013, OpenStreetMap Foundation
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

passwords = data_bag_item("switch2osm", "passwords")

wordpress_site "switch2osm.org" do
  aliases ["www.switch2osm.org", "switch2osm.com", "www.switch2osm.com"]
  directory "/srv/switch2osm.org"
  database_name "switch2osm-blog"
  database_user "switch2osm-user"
  database_password passwords["switch2osm-user"]
end

wordpress_theme "switch2osm.org-picolight" do
  theme "picolight"
  site "switch2osm.org"
  repository "git://github.com/Firefishy/picolight-s2o.git"
  revision "master"
end

wordpress_plugin "switch2osm.org-sitepress-multilingual-cms" do
  plugin "sitepress-multilingual-cms"
  site "switch2osm.org"
  repository "https://git.openstreetmap.org/private/sitepress-multilingual-cms.git"
end

wordpress_plugin "switch2osm.org-wpml-cms-nav" do
  plugin "wpml-cms-nav"
  site "switch2osm.org"
  repository "https://git.openstreetmap.org/private/wpml-cms-nav.git"
end

wordpress_plugin "switch2osm.org-wpml-sticky-links" do
  plugin "wpml-sticky-links"
  site "switch2osm.org"
  repository "https://git.openstreetmap.org/private/wpml-sticky-links.git"
end

wordpress_plugin "switch2osm.org-wpml-string-translation" do
  plugin "wpml-string-translation"
  site "switch2osm.org"
  repository "https://git.openstreetmap.org/private/wpml-string-translation.git"
end

wordpress_plugin "switch2osm.org-wpml-translation-analytics" do
  plugin "wpml-translation-analytics"
  site "switch2osm.org"
  repository "https://git.openstreetmap.org/private/wpml-translation-analytics.git"
end

wordpress_plugin "switch2osm.org-wpml-translation-management" do
  plugin "wpml-translation-management"
  site "switch2osm.org"
  repository "https://git.openstreetmap.org/private/wpml-translation-management.git"
end

wordpress_plugin "switch2osm.org-wpml-xliff" do
  plugin "wpml-xliff"
  site "switch2osm.org"
  repository "https://git.openstreetmap.org/private/wpml-xliff.git"
end

template "/etc/cron.daily/switch2osm-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0o750
  variables :passwords => passwords
end
