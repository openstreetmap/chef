#
# Cookbook:: donate
# Recipe:: default
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

include_recipe "accounts"
include_recipe "apache"
include_recipe "php::fpm"

apache_module "headers"

ssl_certificate "donate.openstreetmap.org" do
  domains ["donate.openstreetmap.org", "donate.openstreetmap.com",
           "donate.openstreetmap.net", "donate.osm.org"]
  notifies :reload, "service[apache2]"
end

php_fpm "donate.openstreetmap.org" do
  action :delete
end

apache_site "donate.openstreetmap.org" do
  template "apache.erb"
end

service "osmf-donate.timer" do
  action [:stop, :disable]
end

systemd_service "osmf-donate" do
  action :delete
end

file "/etc/cron.daily/osmf-donate-backup" do
  action :delete
end
