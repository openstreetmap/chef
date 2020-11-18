#
# Cookbook:: foundation
# Recipe:: board
#
# Copyright:: 2014, OpenStreetMap Foundation
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

passwords = data_bag_item("foundation", "passwords")

mediawiki_site "board.osmfoundation.org" do
  sitename "OSMF Board Wiki"
  metanamespace "OSMFBoard"
  directory "/srv/board.osmfoundation.org"
  fpm_prometheus_port 11004
  database_name "board-wiki"
  database_user "board-wikiuser"
  database_password passwords["board"]["database"]
  admin_password passwords["board"]["admin"]
  logo "/Wiki.png"
  email_contact "webmaster@openstreetmap.org"
  email_sender "webmaster@openstreetmap.org"
  email_sender_name "OSMF Board Wiki"
  private_site true
  recaptcha_public_key "6LflIQATAAAAAMXyDWpba-FgipVzE-aGF4HIR59N"
  recaptcha_private_key passwords["board"]["recaptcha"]
  version "1.34"
end

cookbook_file "/srv/board.osmfoundation.org/Wiki.png" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "644"
end
