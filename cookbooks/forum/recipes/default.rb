#
# Cookbook Name:: forum
# Recipe:: default
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
include_recipe "apache::ssl"
include_recipe "git"
include_recipe "mysql"

passwords = data_bag_item("forum", "passwords")

package "php"
package "php-cli"
package "php-mysql"
package "php-xml"
package "php-apcu"

apache_module "php7.0"
apache_module "rewrite"

ssl_certificate "forum.openstreetmap.org" do
  domains ["forum.openstreetmap.org", "forum.osm.org"]
  fallback_certificate "openstreetmap"
  notifies :reload, "service[apache2]"
end

apache_site "forum.openstreetmap.org" do
  template "apache.erb"
end

directory "/srv/forum.openstreetmap.org" do
  owner "forum"
  group "forum"
  mode 0o755
end

git "/srv/forum.openstreetmap.org/html/" do
  action :sync
  repository "http://github.com/openstreetmap/openstreetmap-forum.git"
  revision "openstreetmap-1.5.10"
  depth 1
  user "forum"
  group "forum"
  notifies :reload, "service[apache2]"
end

directory "/srv/forum.openstreetmap.org/html/cache/" do
  owner "www-data"
  group "www-data"
  mode 0o755
end

directory "/srv/forum.openstreetmap.org/html/img/avatars/" do
  owner "www-data"
  group "www-data"
  mode 0o755
end

template "/srv/forum.openstreetmap.org/html/config.php" do
  source "config.php.erb"
  owner "forum"
  group "www-data"
  mode 0o440
  variables :passwords => passwords
end

mysql_user "forum@localhost" do
  password passwords["database"]
end

mysql_database "forum" do
  permissions "forum@localhost" => :all
end

template "/etc/cron.daily/forum-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0o750
  variables :passwords => passwords
end
