#
# Cookbook:: blog
# Recipe:: birthday
#
# Copyright:: 2024, OpenStreetMap Foundation
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

include_recipe "wordpress"

passwords = data_bag_item("birthday20", "passwords")
# wp2fa_encrypt_keys = data_bag_item("birthday20", "wp2fa_encrypt_keys")

directory "/srv/birthday20.openstreetmap.org" do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

# wordpress_site "birthday20.openstreetmap.org" do
#   aliases ["birthday20.osm.org", "birthday20.openstreetmap.com",
#            "birthday20.openstreetmap.net", "birthday20.openstreetmaps.org"]
#   directory "/srv/birthday20.openstreetmap.org/wp"
#   database_name "osm-birthday20"
#   database_user "osm-birthday20-user"
#   database_password passwords["osm-birthday20-user"]
#   wp2fa_encrypt_key wp2fa_encrypt_keys["key"]
#   fpm_prometheus_port 11403
# end

# wordpress_plugin "birthday20.openstreetmap.org-shareadraft" do
#   action :delete
#   plugin "shareadraft"
#   site "birthday20.openstreetmap.org"
# end

# wordpress_plugin "birthday20.openstreetmap.org-public-post-preview" do
#   plugin "public-post-preview"
#   site "birthday20.openstreetmap.org"
# end

template "/etc/cron.daily/birthday20-backup" do
  source "backup-birthday20.cron.erb"
  owner "root"
  group "root"
  mode "750"
  variables :passwords => passwords
end

ssl_certificate "birthday20.openstreetmap.org" do
  domains ["birthday20.openstreetmap.org", "birthday20.osm.org", "birthday20.openstreetmap.com",
           "birthday20.openstreetmap.net", "birthday20.openstreetmaps.org"]
end
