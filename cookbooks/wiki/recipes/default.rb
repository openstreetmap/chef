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

site_name = node[:wiki][:site_name]

passwords = data_bag_item("wiki", "passwords")

package "lua5.1" # newer versions do not work with Scribuntu!

apache_site "default" do
  action [:disable]
end

mediawiki_site site_name do
  aliases node[:wiki][:site_aliases]

  version node[:wiki][:mediawiki_version]

  fpm_max_children 300
  fpm_start_servers 50
  fpm_min_spare_servers 50
  fpm_max_spare_servers 150
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

  hcaptcha_public_key "b67a410b-955e-4049-b432-f9c00e0202c0"
  hcaptcha_private_key passwords["hcaptcha"]

  namespaces "DE" => { :id => 200, :talk_id => 201 },
             "FR" => { :id => 202, :talk_id => 203 },
             "ES" => { :id => 204, :talk_id => 205 },
             "IT" => { :id => 206, :talk_id => 207 },
             "NL" => { :id => 208, :talk_id => 209 },
             "RU" => { :id => 210, :talk_id => 211 },
             "JA" => { :id => 212, :talk_id => 213 },
             "Proposal" => { :id => 3000, :talk_id => 3001 }

  force_ui_messages %w[mainpage-url mapfeatures-url contributors-url helppage blogs-url shop-url sitesupport-url]

  watch_category_membership true

  site_notice node[:wiki][:site_notice]
  site_readonly node[:wiki][:site_readonly]
end

mediawiki_extension "CodeEditor" do
  site site_name
end

mediawiki_extension "CodeMirror" do
  site site_name
end

mediawiki_extension "Scribunto" do
  site site_name
  template "mw-ext-Scribunto.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "Wikibase" do
  site site_name
  template "mw-ext-Wikibase.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "OsmWikibase" do
  site site_name
  repository "https://github.com/nyurik/OsmWikibase.git"
  reference "master"
end

mediawiki_extension "Echo" do
  site site_name
  template "mw-ext-Echo.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "Thanks" do
  site site_name
  template "mw-ext-Thanks.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "TimedMediaHandler" do
  site site_name
end

mediawiki_extension "MultiMaps" do
  site site_name
  template "mw-ext-MultiMaps.inc.php.erb"
  template_cookbook "wiki"
  variables :thunderforest_key => passwords["thunderforest"]
  action :delete
end

mediawiki_extension "JsonConfig" do
  site site_name
  template "mw-ext-JsonConfig.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "Kartographer" do
  site site_name
  template "mw-ext-Kartographer.inc.php.erb"
  template_cookbook "wiki"
end

mediawiki_extension "TemplateStyles" do
  site site_name
  only_if { node[:wiki][:test_mode] }
end

cookbook_file "/srv/#{site_name}/osm_logo_wiki.png" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "644"
end

template "/srv/#{site_name}/robots.txt" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "644"
  source "robots.txt.erb"
end

cookbook_file "/srv/#{site_name}/favicon.ico" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "644"
end

directory "/srv/#{site_name}/dump" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "0775"
end

systemd_service "wiki-dump" do
  description "Wiki dump"
  type "oneshot"
  exec_start "/usr/bin/php w/maintenance/dumpBackup.php --full --quiet --output=gzip:dump/dump.xml.gz"
  working_directory "/srv/#{site_name}"
  user "wiki"
  nice 19
  sandbox :enable_network => true
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
  read_write_paths "/srv/#{site_name}/dump"
end

systemd_timer "wiki-dump" do
  description "Wiki dump"
  on_calendar "Sun 02:30"
end

service "wiki-dump.timer" do
  action [:enable, :start]
end

systemd_service "wiki-rdf-dump" do
  description "Wiki RDF dump"
  type "oneshot"
  exec_start [
    "/usr/bin/php w/extensions/Wikibase/repo/maintenance/dumpRdf.php --wiki wiki --format ttl --flavor full-dump --entity-type item --entity-type property --no-cache --output /tmp/wikibase-rdf.ttl",
    "/bin/gzip -9 /tmp/wikibase-rdf.ttl",
    "/bin/mv /tmp/wikibase-rdf.ttl.gz /srv/#{site_name}/dump/wikibase-rdf.ttl.gz"
  ]
  working_directory "/srv/#{site_name}"
  user "wiki"
  sandbox :enable_network => true
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
  read_write_paths "/srv/#{site_name}/dump"
end

systemd_timer "wiki-rdf-dump" do
  description "Wiki RDF dump"
  on_calendar "04:00"
end

service "wiki-rdf-dump.timer" do
  action [:enable, :start]
end
