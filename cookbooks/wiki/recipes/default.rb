#
# Cookbook Name:: wiki.openstreetmap.org
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

# include_recipe "squid"

include_recipe "mediawiki"

passwords = data_bag_item("wiki", "passwords")

apache_site "default" do
  action [:disable]
end

mediawiki_site "wiki.openstreetmap.org" do
  aliases ["wiki.osm.org", "wiki.openstreetmap.com", "wiki.openstreetmap.net",
           "wiki.openstreetmap.ca", "wiki.openstreetmap.eu",
           "wiki.openstreetmap.pro", "wiki.openstreetmaps.org"]
  directory "/srv/wiki.openstreetmap.org"

  database_name "wiki"
  database_user "wiki-user"
  database_password passwords["database"]

  admin_password passwords["admin"]

  logo "/osm_logo_wiki.png"

  email_contact "webmaster@openstreetmap.org"
  email_sender "wiki@noreply.openstreetmap.org"
  email_sender_name "OpenStreetMap Wiki"

  metanamespace "OpenStreetMap"

  recaptcha_public_key "6LdFIQATAAAAAMwtHeI8KDgPqvRbXeNYSq1gujKz"
  recaptcha_private_key passwords["recaptcha"]

  # site_notice "MAINTENANCE: WIKI READ-ONLY UNTIL Monday 16 May 2016 - 11:00am UTC/GMT."
  # site_readonly "MAINTENANCE: WIKI READ-ONLY UNTIL Monday 16 May 2016 - 11:00am UTC/GMT."
end

cookbook_file "/srv/wiki.openstreetmap.org/osm_logo_wiki.png" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode 0o644
end

template "/srv/wiki.openstreetmap.org/robots.txt" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode 0o644
  source "robots.txt.erb"
end

cookbook_file "/srv/wiki.openstreetmap.org/favicon.ico" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode 0o644
end

directory "/srv/dump.wiki.openstreetmap.org" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "0775"
end

apache_site "dump.wiki.openstreetmap.org" do
  template "apache_wiki_dump.erb"
  directory "/srv/dump.wiki.openstreetmap.org"
  variables :aliases => "dump.wiki.osm.org"
end

template "/etc/cron.d/wiki-osm-org-dump" do
  owner "root"
  group "root"
  mode 0o644
  source "cron_wiki_dump.erb"
end

mediawiki_extension "MobileFrontend" do
  site "wiki.openstreetmap.org"
  template "mw-ext-MobileFrontend.inc.php.erb"
  update_site false
end
