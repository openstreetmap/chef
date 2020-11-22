#
# Cookbook:: civicrm
# Recipe:: default
#
# Copyright:: 2011, OpenStreetMap Foundation
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
include_recipe "mysql"

package %w[
  php-xml
  php-curl
  rsync
  unzip
  wkhtmltopdf
  php-bcmath
]

cache_dir = Chef::Config[:file_cache_path]

passwords = data_bag_item("civicrm", "passwords")

database_password = passwords["database"]
site_key = passwords["key"]

mysql_user "civicrm@localhost" do
  password database_password
end

mysql_database "civicrm" do
  permissions "civicrm@localhost" => :all
end

wordpress_site "join.osmfoundation.org" do
  aliases "crm.osmfoundation.org"
  database_name "civicrm"
  database_user "civicrm"
  database_password database_password
  fpm_prometheus_port 11301
end

wordpress_theme "osmblog-wp-theme" do
  site "join.osmfoundation.org"
  repository "https://github.com/harry-wood/osmblog-wp-theme.git"
end

wordpress_plugin "registration-honeypot" do
  site "join.osmfoundation.org"
end

wordpress_plugin "sitepress-multilingual-cms" do
  site "join.osmfoundation.org"
  repository "https://git.openstreetmap.org/private/sitepress-multilingual-cms.git"
  not_if { ENV["TEST_KITCHEN"] }
end

wordpress_plugin "contact-form-7" do
  site "join.osmfoundation.org"
end

wordpress_plugin "civicrm-admin-utilities" do
  site "join.osmfoundation.org"
end

civicrm_version = node[:civicrm][:version]
civicrm_directory = "/srv/join.osmfoundation.org/wp-content/plugins/civicrm"

directory "/opt/civicrm-#{civicrm_version}" do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

remote_file "#{cache_dir}/civicrm-#{civicrm_version}-wordpress.zip" do
  action :create_if_missing
  source "https://download.civicrm.org/civicrm-#{civicrm_version}-wordpress.zip"
  owner "wordpress"
  group "wordpress"
  mode "644"
  backup false
end

remote_file "#{cache_dir}/civicrm-#{civicrm_version}-l10n.tar.gz" do
  action :create_if_missing
  source "https://download.civicrm.org/civicrm-#{civicrm_version}-l10n.tar.gz"
  owner "wordpress"
  group "wordpress"
  mode "644"
  backup false
end

execute "#{cache_dir}/civicrm-#{civicrm_version}-wordpress.zip" do
  action :nothing
  command "unzip -o -qq #{cache_dir}/civicrm-#{civicrm_version}-wordpress.zip"
  cwd "/opt/civicrm-#{civicrm_version}"
  user "wordpress"
  group "wordpress"
  subscribes :run, "remote_file[#{cache_dir}/civicrm-#{civicrm_version}-wordpress.zip]", :immediately
end

execute "#{cache_dir}/civicrm-#{civicrm_version}-l10n.tar.gz" do
  action :nothing
  command "tar -zxf #{cache_dir}/civicrm-#{civicrm_version}-l10n.tar.gz"
  cwd "/opt/civicrm-#{civicrm_version}/civicrm"
  user "wordpress"
  group "wordpress"
  subscribes :run, "remote_file[#{cache_dir}/civicrm-#{civicrm_version}-l10n.tar.gz]", :immediately
end

execute "/opt/civicrm-#{civicrm_version}/civicrm" do
  action :nothing
  command "rsync --archive --delete /opt/civicrm-#{civicrm_version}/civicrm/ #{civicrm_directory}"
  user "wordpress"
  group "wordpress"
  subscribes :run, "execute[#{cache_dir}/civicrm-#{civicrm_version}-wordpress.zip]", :immediately
  subscribes :run, "execute[#{cache_dir}/civicrm-#{civicrm_version}-l10n.tar.gz]", :immediately
end

directory "/srv/join.osmfoundation.org/wp-content/uploads" do
  owner "www-data"
  group "www-data"
  mode "755"
end

extensions_directory = "/srv/join.osmfoundation.org/wp-content/plugins/civicrm-extensions"

directory extensions_directory do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

node[:civicrm][:extensions].each_value do |details|
  git "#{extensions_directory}/#{details[:name]}" do
    action :sync
    repository details[:repository]
    revision details[:revision]
    user "wordpress"
    group "wordpress"
  end
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
  line.gsub!(/%%crmRoot%%/, "#{civicrm_directory}/civicrm/")
  line.gsub!(/%%templateCompileDir%%/, "/srv/join.osmfoundation.org/wp-content/uploads/civicrm/templates_c/")
  line.gsub!(/%%baseURL%%/, "http://join.osmfoundation.org/")
  line.gsub!(/%%siteKey%%/, site_key)
  line.gsub!(%r{// *define\('CIVICRM_CMSDIR', '/path/to/install/root/'\);}, "define('CIVICRM_CMSDIR', '/srv/join.osmfoundation.org');")

  line
end

file "#{civicrm_directory}/civicrm.settings.php" do
  owner "wordpress"
  group "wordpress"
  mode "644"
  content settings
end

cron_d "osmf-crm" do
  minute "*/15"
  user "www-data"
  command "php #{civicrm_directory}/civicrm/bin/cli.php -s join.osmfoundation.org -u batch -p \"#{passwords['batch']}\" -e Job -a execute 2>&1 | egrep -v '^PHP (Deprecated|Warning):'"
  mailto "admins@openstreetmap.org"
end

template "/etc/cron.daily/osmf-crm-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "750"
  variables :passwords => passwords
end
