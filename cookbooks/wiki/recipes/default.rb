#
# Cookbook:: wiki.openstreetmap.org
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

include_recipe "mediawiki"

passwords = data_bag_item("wiki", "passwords")

package "lua5.1" # newer versions do not work with Scribuntu!

apache_site "default" do
  action [:disable]
end

mediawiki_site "wiki.openstreetmap.org" do
  aliases ["wiki.osm.org", "wiki.openstreetmap.com", "wiki.openstreetmap.net",
           "wiki.openstreetmap.ca", "wiki.openstreetmap.eu",
           "wiki.openstreetmap.pro", "wiki.openstreetmaps.org"]
  directory "/srv/wiki.openstreetmap.org"

  fpm_max_children 50
  fpm_start_servers 10
  fpm_min_spare_servers 10
  fpm_max_spare_servers 20
  fpm_prometheus_port 9253

  database_name "wiki"
  database_user "wiki-user"
  database_password passwords["database"]

  admin_password passwords["admin"]

  logo "/osm_logo_wiki.png"

  email_contact "webmaster@openstreetmap.org"
  email_sender "wiki@noreply.openstreetmap.org"
  email_sender_name "OpenStreetMap Wiki"

  metanamespace "Wiki"

  recaptcha_public_key "6LdFIQATAAAAAMwtHeI8KDgPqvRbXeNYSq1gujKz"
  recaptcha_private_key passwords["recaptcha"]

  # site_notice "MAINTENANCE: WIKI READ-ONLY UNTIL Monday 16 May 2016 - 11:00am UTC/GMT."
  # site_readonly "MAINTENANCE: WIKI READ-ONLY UNTIL Monday 16 May 2016 - 11:00am UTC/GMT."
end

mediawiki_extension "CodeEditor" do
  site "wiki.openstreetmap.org"
end

mediawiki_extension "CodeMirror" do
  site "wiki.openstreetmap.org"
end

mediawiki_extension "Scribunto" do
  site "wiki.openstreetmap.org"
  template "mw-ext-Scribunto.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "Wikibase" do
  site "wiki.openstreetmap.org"
  template "mw-ext-Wikibase.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "OsmWikibase" do
  site "wiki.openstreetmap.org"
  repository "https://github.com/nyurik/OsmWikibase.git"
  reference "master"
end

mediawiki_extension "Echo" do
  site "wiki.openstreetmap.org"
  template "mw-ext-Echo.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "Thanks" do
  site "wiki.openstreetmap.org"
  template "mw-ext-Thanks.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "TimedMediaHandler" do
  site "wiki.openstreetmap.org"
end

mediawiki_extension "MultiMaps" do
  site "wiki.openstreetmap.org"
  template "mw-ext-MultiMaps.inc.php.erb"
  template_cookbook "wiki"
  variables :thunderforest_key => passwords["thunderforest"]
end

cookbook_file "/srv/wiki.openstreetmap.org/osm_logo_wiki.png" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "644"
end

template "/srv/wiki.openstreetmap.org/robots.txt" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "644"
  source "robots.txt.erb"
end

cookbook_file "/srv/wiki.openstreetmap.org/favicon.ico" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "644"
end

directory "/srv/wiki.openstreetmap.org/dump" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "0775"
end

cron_d "wiki-dump" do
  minute "0"
  hour "2"
  user "wiki"
  command "cd /srv/wiki.openstreetmap.org && php w/maintenance/dumpBackup.php --full --quiet --output=gzip:dump/dump.xml.gz"
end
