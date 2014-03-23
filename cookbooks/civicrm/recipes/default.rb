#
# Cookbook Name:: civicrm
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

include_recipe "wordpress"
include_recipe "mysql"

passwords = data_bag_item("civicrm", "passwords")

database_password = passwords["database"]
admin_password = passwords["admin"]
site_key = passwords["key"]

mysql_user "civicrm@localhost" do
  password database_password
end

mysql_database "civicrm" do
  permissions "civicrm@localhost" => :all
end

wordpress_site "crm.osmfoundation.org" do
  ssl_enabled true
  database_name "civicrm"
  database_user "civicrm"
  database_password database_password
end

civicrm_version = node[:civicrm][:version]
civicrm_directory = "/srv/crm.osmfoundation.org/wp-content/plugins/civicrm"

directory "/opt/civicrm-#{civicrm_version}" do
  owner "root"
  group "root"
  mode 0755
end

remote_file "/var/cache/chef/civicrm-#{civicrm_version}-wordpress.zip" do
  action :create_if_missing
  source "http://downloads.sourceforge.net/project/civicrm/civicrm-stable/#{civicrm_version}/civicrm-#{civicrm_version}-wordpress.zip"
  owner "root"
  group "root"
  mode 0644
  backup false
end

remote_file "/var/cache/chef/civicrm-#{civicrm_version}-l10n.tar.gz" do
  action :create_if_missing
  source "http://downloads.sourceforge.net/project/civicrm/civicrm-stable/#{civicrm_version}/civicrm-#{civicrm_version}-l10n.tar.gz"
  owner "root"
  group "root"
  mode 0644
  backup false
end

execute "/var/cache/chef/civicrm-#{civicrm_version}-wordpress.zip" do
  action :nothing
  command "unzip -qq /var/cache/chef/civicrm-#{civicrm_version}-wordpress.zip"
  cwd "/opt/civicrm-#{civicrm_version}"
  user "root"
  group "root"
  subscribes :run, "remote_file[/var/cache/chef/civicrm-#{civicrm_version}-wordpress.zip]"
end

execute "/var/cache/chef/civicrm-#{civicrm_version}-l10n.tar.gz" do
  action :nothing
  command "tar -zxf /var/cache/chef/civicrm-#{civicrm_version}-l10n.tar.gz"
  cwd "/opt/civicrm-#{civicrm_version}/civicrm"
  user "root"
  group "root"
  subscribes :run, "remote_file[/var/cache/chef/civicrm-#{civicrm_version}-l10n.tar.gz]"
end

link civicrm_directory do
  to "/opt/civicrm-#{civicrm_version}/civicrm"
end

directory "/srv/crm.osmfoundation.org/wp-content/plugins/files" do
  owner "www-data"
  group "www-data"
  mode 0755
end

settings = edit_file "#{civicrm_directory}/civicrm/templates/CRM/common/civicrm.settings.php.template" do |line|
  line.gsub!(/%%cms%%/, "WordPress")
  line.gsub!(/%%CMSdbUser%%/, "civicrm")
  line.gsub!(/%%CMSdbPass%%/, database_password)
  line.gsub!(/%%CMSdbHost%%/, "localhost")
  line.gsub!(/%%CMSdbName%%/, "civicrm")
  line.gsub!(/%%dbUser%%/, "civicrm")
  line.gsub!(/%%dbPass%%/, database_password)
  line.gsub!(/%%dbHost%%/, "localhost")
  line.gsub!(/%%dbName%%/, "civicrm")
  line.gsub!(/%%crmRoot%%/, "#{civicrm_directory}/civicrm")
  line.gsub!(/%%templateCompileDir%%/, "/srv/crm.osmfoundation.org/wp-content/plugins/files/civicrm/templates_c")
  line.gsub!(/%%baseURL%%/, "http://crm.osmfoundation.org/")
  line.gsub!(/%%siteKey%%/, site_key)

  line
end

file "#{civicrm_directory}/civicrm/civicrm.settings.php" do
  owner "root"
  group "root"
  mode 0644
  content settings
end

template "/etc/cron.daily/osmf-crm-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0750
  variables :passwords => passwords
end
