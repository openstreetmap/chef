#
# Cookbook:: forum
# Recipe:: default
#
# Copyright:: 2014, OpenStreetMap Foundation
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
include_recipe "php::apache"

cache_dir = Chef::Config[:file_cache_path]

passwords = data_bag_item("forum", "passwords")

package %w[
  php-cli
  php-mysql
  php-xml
  php-apcu
  unzip
]

apache_module "env"
apache_module "rewrite"

ssl_certificate "forum.openstreetmap.org" do
  domains ["forum.openstreetmap.org", "forum.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "forum.openstreetmap.org" do
  template "apache.erb"
end

directory "/srv/forum.openstreetmap.org" do
  owner "forum"
  group "forum"
  mode "755"
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

remote_file "#{cache_dir}/air3_v0.8.zip" do
  action :create_if_missing
  source "https://fluxbb.org/resources/styles/air3/releases/0.8/air3_v0.8.zip"
  owner "root"
  group "root"
  mode "644"
  backup false
end

execute "#{cache_dir}/air3_v0.8.zip" do
  action :nothing
  command "unzip -o -qq #{cache_dir}/air3_v0.8.zip Air3.css 'Air3/*'"
  cwd "/srv/forum.openstreetmap.org/html/style"
  user "forum"
  group "forum"
  subscribes :run, "remote_file[#{cache_dir}/air3_v0.8.zip]", :immediately
end

directory "/srv/forum.openstreetmap.org/html/cache/" do
  owner "www-data"
  group "www-data"
  mode "755"
end

directory "/srv/forum.openstreetmap.org/html/img/avatars/" do
  owner "www-data"
  group "www-data"
  mode "755"
end

template "/srv/forum.openstreetmap.org/html/config.php" do
  source "config.php.erb"
  owner "forum"
  group "www-data"
  mode "440"
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
  mode "750"
  variables :passwords => passwords
end
