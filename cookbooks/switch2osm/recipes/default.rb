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
#     http://www.apache.org/licenses/LICENSE-2.0
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
  ssl_enabled true
  database_name "switch2osm-blog"
  database_user "switch2osm-user"
  database_password passwords["switch2osm-user"]
end

wordpress_theme "switch2osm.org-picolight" do
  name "picolight"
  site "switch2osm.org"
  repository "git://github.com/Firefishy/picolight-s2o.git"
  revision "master"
end

wordpress_plugin "switch2osm.org-sitepress-multilingual-cms" do
  name "sitepress-multilingual-cms"
  site "switch2osm.org"
  repository "git://chef.openstreetmap.org/sitepress-multilingual-cms.git"
end

wordpress_plugin "switch2osm.org-wpml-cms-nav" do
  name "wpml-cms-nav"
  site "switch2osm.org"
  repository "git://chef.openstreetmap.org/wpml-cms-nav.git"
end

wordpress_plugin "switch2osm.org-wpml-sticky-links" do
  name "wpml-sticky-links"
  site "switch2osm.org"
  repository "git://chef.openstreetmap.org/wpml-sticky-links.git"
end

wordpress_plugin "switch2osm.org-wpml-string-translation" do
  name "wpml-string-translation"
  site "switch2osm.org"
  repository "git://chef.openstreetmap.org/wpml-string-translation.git"
end

wordpress_plugin "switch2osm.org-wpml-translation-analytics" do
  name "wpml-translation-analytics"
  site "switch2osm.org"
  repository "git://chef.openstreetmap.org/wpml-translation-analytics.git"
end

wordpress_plugin "switch2osm.org-wpml-translation-management" do
  name "wpml-translation-management"
  site "switch2osm.org"
  repository "git://chef.openstreetmap.org/wpml-translation-management.git"
end

wordpress_plugin "switch2osm.org-wpml-xliff" do
  name "wpml-xliff"
  site "switch2osm.org"
  repository "git://chef.openstreetmap.org/wpml-xliff.git"
end

template "/etc/cron.daily/switch2osm-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0o750
  variables :passwords => passwords
end
