#
# Cookbook:: trac
# Recipe:: default
#
# Copyright:: 2012, OpenStreetMap Foundation
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

apache_module "rewrite"

directory "/srv/trac.openstreetmap.org" do
  owner "root"
  group "root"
  mode "0755"
end

cookbook_file "/srv/trac.openstreetmap.org/tickets.map" do
  owner "root"
  group "root"
  mode "0644"
end

ssl_certificate "trac.openstreetmap.org" do
  domains ["trac.openstreetmap.org", "trac.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "trac.openstreetmap.org" do
  template "apache.erb"
  variables :user => "trac", :group => "trac", :aliases => ["trac.osm.org"]
end
