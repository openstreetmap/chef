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

mediawiki_site  "wiki.osmfoundation.org" do
  aliases "www.osmfoundation.org", "osmfoundation.org"
  directory "/srv/wiki.osmfoundation.org"
  database_name "osmf-wiki"
  database_username "osmf-wikiuser"
  database_password passwords["wiki"]["database"]
  skin "osmf"
  logo "/Wiki.png"
  email_contact "webmaster@openstreetmap.org"
  email_sender "webmaster@openstreetmap.org"
  email_sender_name "OSMF Wiki"
  private_accounts true
  recaptcha_public_key "6LflIQATAAAAAMXyDWpba-FgipVzE-aGF4HIR59N"
  recaptcha_private_key passwords["wiki"]["recaptcha"]
end

cookbook_file "/srv/wiki.osmfoundation.org/Wiki.png" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode 0644
end

subversion "/srv/wiki.osmfoundation.org/w/skins/osmf-skin" do
  repository "http://svn.openstreetmap.org/extensions/mediawiki/osmf"
  user node[:mediawiki][:user]
  group node[:mediawiki][:group]
end

link "/srv/wiki.osmfoundation.org/w/skins/osmf" do
  to "osmf-skin/osmf"
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
end

link "/srv/wiki.osmfoundation.org/w/skins/osmf.deps.php" do
  to "osmf-skin/osmf.deps.php"
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
end

link "/srv/wiki.osmfoundation.org/w/skins/osmf.php" do
  to "osmf-skin/osmf.php"
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
end
