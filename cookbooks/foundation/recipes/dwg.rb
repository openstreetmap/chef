#
# Cookbook:: foundation
# Recipe:: dwg
#
# Copyright:: 2016, OpenStreetMap Foundation
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

mediawiki_site "dwg.osmfoundation.org" do
  sitename "OSMF Data Working Group Wiki"
  metanamespace "OSMFDWG"
  directory "/srv/dwg.osmfoundation.org"
  fpm_prometheus_port 11002
  database_name "dwg-wiki"
  database_user "dwg-wikiuser"
  database_password passwords["dwg"]["database"]
  admin_password passwords["dwg"]["admin"]
  logo "/Wiki.png"
  email_contact "webmaster@openstreetmap.org"
  email_sender "wiki@noreply.openstreetmap.org"
  email_sender_name "OSMF Board Wiki"
  private_site true
  extra_file_extensions %w[pptx]
  version "1.39"
end

cookbook_file "/srv/dwg.osmfoundation.org/Wiki.png" do
  owner node[:mediawiki][:user]
  group node[:mediawiki][:group]
  mode "644"
end
