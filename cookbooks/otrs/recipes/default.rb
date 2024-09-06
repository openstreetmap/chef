#
# Cookbook:: otrs
# Recipe:: default
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

include_recipe "accounts"
include_recipe "apache"
include_recipe "exim"
include_recipe "postgresql"
include_recipe "tools"

passwords = data_bag_item("otrs", "passwords")

apache_module "perl" do
  package "libapache2-mod-perl2"
end

apache_module "deflate"
apache_module "headers"
apache_module "rewrite"

database_cluster = node[:otrs][:database_cluster]
database_name = node[:otrs][:database_name]
database_user = node[:otrs][:database_user]
database_password = passwords[node[:otrs][:database_password]]
site = node[:otrs][:site]
site_aliases = node[:otrs][:site_aliases] || []

postgresql_user database_user do
  cluster database_cluster
  password database_password
end

postgresql_database database_name do
  cluster database_cluster
  owner database_user
end

package "dbconfig-common"

template "/etc/dbconfig-common/otrs2.conf" do
  source "dbconfig.config.erb"
  owner "root"
  group "root"
  mode "600"
  variables :database_name => database_name,
            :database_user => database_user,
            :database_password => database_password,
            :database_cluster => database_cluster
end

apt_package "otrs2"

# Ensure debconf is repopulated on a dbconfig change
execute "dpkg-reconfigure-otrs2" do
  action :nothing
  command "dpkg-reconfigure -fnoninteractive otrs2"
  subscribes :run, "template[/etc/dbconfig-common/otrs2.conf]"
end

# Disable deb otrs2 apache config
apache_conf "otrs2" do
  action :disable
end

# Disable deb otrs2 cron job
file "/etc/cron.d/otrs2" do
  action :delete
  manage_symlink_source true
end

systemd_service "otrs" do
  description "OTRS Daemon"
  type "forking"
  user "otrs"
  group "www-data"
  exec_start_pre "-/usr/share/otrs/bin/otrs.Daemon.pl stop" # Stop if race with deb cron
  exec_start "/usr/share/otrs/bin/otrs.Daemon.pl start"
  private_tmp true
  protect_system "strict"
  protect_home false
  runtime_directory "otrs"
  runtime_directory_mode 0o770
  runtime_directory_preserve true
  read_write_paths ["/var/lib/otrs", "/run/otrs", "/var/log/exim4", "/var/spool/exim4"]
end

service "otrs" do
  action [:enable, :start]
  subscribes :restart, "apt_package[otrs2]"
  subscribes :restart, "systemd_service[otrs]"
end

ssl_certificate site do
  domains [site] + site_aliases
  notifies :reload, "service[apache2]"
end

apache_site site do
  template "apache.erb"
  variables :aliases => site_aliases
end

template "/etc/cron.daily/otrs-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end
