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

package "php5"
package "php5-cli"
package "php5-mysql"
package "php-apc"

apache_module "php5"

apache_site "default" do
  action [ :disable ]
end

apache_site "forum.openstreetmap.org" do
  template "apache.erb"
end

directory "/srv/forum.openstreetmap.org" do
  owner "forum"
  group "forum"
  mode 0755
end

git "/srv/forum.openstreetmap.org/html/" do
  action :sync
  repository "http://github.com/fluxbb/fluxbb.git"
  revision "refs/tags/fluxbb-1.5.6"
  depth 1
  user "forum"
  group "forum"
end

directory "/srv/forum.openstreetmap.org/html/cache/" do
  owner "www-data"
  group "www-data"
  mode 0755
end

directory "/srv/forum.openstreetmap.org/html/img/avatars/" do
  owner "www-data"
  group "www-data"
  mode 0755
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
  mode 0750
  variables :passwords => passwords
end
