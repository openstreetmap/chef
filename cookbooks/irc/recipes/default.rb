#
# Cookbook:: irc
# Recipe:: default
#
# Copyright:: 2011, OpenStreetMap Foundation
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

include_recipe "apache"

ssl_certificate "irc.openstreetmap.org" do
  domains ["irc.openstreetmap.org", "irc.osm.org"]
  notifies :reload, "service[apache2]"
end

directory "/srv/irc.openstreetmap.org" do
  owner "root"
  group "root"
  mode "755"
end

remote_directory "/srv/irc.openstreetmap.org/html" do
  source "html"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "644"
end

apache_site "irc.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/irc.openstreetmap.org/html"
  variables :aliases => ["irc.osm.org"]
end
