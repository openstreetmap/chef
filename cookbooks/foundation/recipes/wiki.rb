#
# Cookbook Name:: foundation
# Recipe:: wiki
#
# Copyright 2014, OpenStreetMap Foundation
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

include_recipe "mediawiki"

passwords = data_bag_item("foundation", "passwords")

mediawiki_site "wiki.osmfoundation.org" do
  aliases ["www.osmfoundation.org", "osmfoundation.org",
           "foundation.openstreetmap.org", "foundation.osm.org"]
  sitename "OpenStreetMap Foundation"
  directory "/srv/wiki.osmfoundation.org"
  ssl_enabled true
  database_name "osmf-wiki"
  database_user "osmf-wikiuser"
  database_password passwords["wiki"]["database"]
  admin_password passwords["wiki"]["admin"]
  skin "osmf"
  logo "/Wiki.png"
  email_contact "webmaster@openstreetmap.org"
  email_sender "webmaster@openstreetmap.org"
  email_sender_name "OSMF Wiki"
  private_accounts true
  recaptcha_public_key "6LflIQATAAAAAMXyDWpba-FgipVzE-aGF4HIR59N"
  recaptcha_private_key passwords["wiki"]["recaptcha"]
  extra_file_extensions ["mp3"]
end

mediawiki_skin "osmf" do
  site "wiki.osmfoundation.org"
  repository "git://github.com/openstreetmap/mediawiki-skins-osmf.git"
  revision "master"
end

mediawiki_skin "OSMFoundation" do
  site "wiki.osmfoundation.org"
  repository "git://github.com/osmfoundation/osmf-mediawiki-skin.git"
  revision "master"
  legacy False
end

cookbook_file "/srv/wiki.osmfoundation.org/Wiki.png" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode 0o644
end
