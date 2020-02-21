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
include_recipe "mysql"
include_recipe "git"

package %w[
  php
  php-cli
  php-curl
  php-mysql
  php-gd
]

apache_module "php7.2"

apache_module "headers"

passwords = data_bag_item("donate", "passwords")

database_password = passwords["database"]

mysql_user "donate@localhost" do
  password database_password
end

mysql_database "donate" do
  permissions "donate@localhost" => :all
end

directory "/srv/donate.openstreetmap.org" do
  owner "donate"
  group "donate"
  mode 0o755
end

git "/srv/donate.openstreetmap.org" do
  action :sync
  repository "git://github.com/osmfoundation/donation-drive.git"
  depth 1
  user "donate"
  group "donate"
end

directory "/srv/donate.openstreetmap.org/data" do
  owner "donate"
  group "donate"
  mode 0o755
end

template "/srv/donate.openstreetmap.org/scripts/db-connect.inc.php" do
  source "db-connect.inc.php.erb"
  owner "root"
  group "donate"
  mode 0o644
  variables :passwords => passwords
end

ssl_certificate "donate.openstreetmap.org" do
  domains ["donate.openstreetmap.org", "donate.openstreetmap.com",
           "donate.openstreetmap.net", "donate.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "donate.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/cron.d/osmf-donate" do
  source "cron.erb"
  owner "root"
  group "root"
  mode 0o600
  variables :passwords => passwords
end

template "/etc/cron.daily/osmf-donate-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0o750
  variables :passwords => passwords
end
