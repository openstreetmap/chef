#
# Cookbook Name:: thinkup
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

include_recipe "apache"
include_recipe "mysql"

passwords = data_bag_item("thinkup", "passwords")

package "php5"
package "php5-cli"
package "php5-curl"
package "php5-mysql"
package "php5-gd"

package "php-apc"

apache_module "php5"

apache_site "thinkup.openstreetmap.org" do
  template "apache.erb"
end

mysql_user "thinkup@localhost" do
  password passwords["database"]
end

mysql_database "thinkup" do
  permissions "thinkup@localhost" => :all
end

git "/srv/thinkup.openstreetmap.org" do
  action :sync
  repository "git://github.com/ginatrapani/ThinkUp.git"
  revision "v1.2.1"
  user "root"
  group "root"
  notifies :reload, "service[apache2]"
end

directory "/srv/thinkup.openstreetmap.org/logs" do
  owner "thinkup"
  group "thinkup"
  mode "0755"
end

directory "/srv/thinkup.openstreetmap.org/logs/archive" do
  owner "thinkup"
  group "thinkup"
  mode "0755"
end

directory "/srv/thinkup.openstreetmap.org/webapp/data" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

directory "/srv/thinkup.openstreetmap.org/webapp/_lib/view/compiled_view" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

thinkup_config = edit_file "/srv/thinkup.openstreetmap.org/webapp/config.sample.inc.php" do |line|
  line.gsub!(/^(\$THINKUP_CFG\['site_root_path'\] *=) '[^']*';$/, "\\1 '/';")
  line.gsub!(/^(\$THINKUP_CFG\['timezone'\] *=) '[^']*';$/, "\\1 'Europe/London';")
  line.gsub!(/^(\$THINKUP_CFG\['db_user'\] *=) '[^']*';$/, "\\1 'thinkup';")
  line.gsub!(/^(\$THINKUP_CFG\['db_password'\] *=) '[^']*';$/, "\\1 '#{passwords["database"]}';")
  line.gsub!(/^(\$THINKUP_CFG\['db_name'\] *=) '[^']*';$/, "\\1 'thinkup';")

  line
end

file "/srv/thinkup.openstreetmap.org/webapp/config.inc.php" do
  owner "root"
  group "root"
  mode 0644
  content thinkup_config
  notifies :reload, "service[apache2]"
end

thinkup_cron = edit_file "/srv/thinkup.openstreetmap.org/extras/cron/config.sample" do |line|
  line.gsub!(/^thinkup="[^"]*"$/, "thinkup=\"/srv/thinkup.openstreetmap.org\"")
  line.gsub!(/^thinkup_username="[^"]*"$/, "thinkup_username=\"openstreetmap@jonno.cix.co.uk\"")
  line.gsub!(/^thinkup_password="[^"]*"$/, "thinkup_password=\"#{passwords["admin"]}\"")
  line.gsub!(/^php="[^"]*"$/, "php=\"/usr/bin/php\"")
  line.gsub!(/^#crawl_interval=[0-9]+$/, "crawl_interval=30")

  line
end

file "/srv/thinkup.openstreetmap.org/extras/cron/config" do
  owner "root"
  group "thinkup"
  mode 0640
  content thinkup_cron
end

template "/etc/cron.d/thinkup" do
  source "cron.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/cron.daily/thinkup-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0750
  variables :passwords => passwords
end
