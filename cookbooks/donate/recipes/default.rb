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
include_recipe "git"
include_recipe "mysql"
include_recipe "php::fpm"

package %w[
  php-cli
  php-curl
  php-mysql
  php-gd
]

apache_module "headers"
apache_module "proxy"
apache_module "proxy_fcgi"

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
  mode "755"
end

git "/srv/donate.openstreetmap.org" do
  action :sync
  repository "https://github.com/osmfoundation/donation-drive.git"
  depth 1
  user "donate"
  group "donate"
end

directory "/srv/donate.openstreetmap.org/data" do
  owner "donate"
  group "donate"
  mode "755"
end

template "/srv/donate.openstreetmap.org/scripts/db-connect.inc.php" do
  source "db-connect.inc.php.erb"
  owner "root"
  group "donate"
  mode "644"
  variables :passwords => passwords
end

ssl_certificate "donate.openstreetmap.org" do
  domains ["donate.openstreetmap.org", "donate.openstreetmap.com",
           "donate.openstreetmap.net", "donate.osm.org"]
  notifies :reload, "service[apache2]"
end

php_fpm "donate.openstreetmap.org" do
  php_admin_values "open_basedir" => "/srv/donate.openstreetmap.org/:/usr/share/php/:/tmp/",
                   "disable_functions" => "exec,shell_exec,system,passthru,popen,proc_open"
  prometheus_port 11101
end

apache_site "donate.openstreetmap.org" do
  template "apache.erb"
end

cron_d "osmf-donate" do
  minute "*/2"
  user "donate"
  command "cd /srv/donate.openstreetmap.org/scripts/; /usr/bin/php /srv/donate.openstreetmap.org/scripts/update_csv_donate2016.php"
end

template "/etc/cron.daily/osmf-donate-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "750"
  variables :passwords => passwords
end
