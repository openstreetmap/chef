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
  wkhtmltopdf
  php-bcmath
  php-intl
]

apache_module "rewrite"

cache_dir = Chef::Config[:file_cache_path]

passwords = data_bag_item("civicrm", "passwords")
wp2fa_encrypt_keys = data_bag_item("civicrm", "wp2fa_encrypt_keys")

database_password = passwords["database"]
site_key = passwords["site_key"]
cred_keys = passwords["cred_keys"]
sign_keys = passwords["sign_keys"]

mysql_user "civicrm@localhost" do
  password database_password
end

mysql_database "civicrm" do
  permissions "civicrm@localhost" => :all
end

wordpress_site "supporting.openstreetmap.org" do
  aliases %w[
    crm.osmfoundation.org
    donate.openstreetmap.org
    donate.openstreetmap.com
    donate.openstreetmap.net
    donate.osm.org
    join.osmfoundation.org
    supporting.osmfoundation.org
    support.osmfoundation.org
    support.openstreetmap.org
    supporting.osm.org
    support.osm.org
  ]
  database_name "civicrm"
  database_user "civicrm"
  database_password database_password
  wp2fa_encrypt_key wp2fa_encrypt_keys["key"]
  fpm_prometheus_port 11301
end

wordpress_plugin "civicrm-wp-piwik" do
  plugin "wp-piwik"
  site "supporting.openstreetmap.org"
end

wordpress_plugin "registration-honeypot" do
  site "supporting.openstreetmap.org"
end

wordpress_plugin "contact-form-7" do
  site "supporting.openstreetmap.org"
end

wordpress_plugin "civicrm-admin-utilities" do
  site "supporting.openstreetmap.org"
end

wordpress_plugin "host-webfonts-local" do
  site "supporting.openstreetmap.org"
end

wordpress_theme "morden" do
  site "supporting.openstreetmap.org"
  repository "https://public-api.wordpress.com/rest/v1/themes/download/morden.zip"
end

wordpress_theme "varia" do
  site "supporting.openstreetmap.org"
  repository "https://public-api.wordpress.com/rest/v1/themes/download/varia.zip"
end

civicrm_version = node[:civicrm][:version]
civicrm_directory = "/srv/supporting.openstreetmap.org/wp-content/plugins/civicrm"

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

archive_file "#{cache_dir}/civicrm-#{civicrm_version}-wordpress.zip" do
  action :nothing
  destination "/opt/civicrm-#{civicrm_version}"
  overwrite true
  owner "wordpress"
  group "wordpress"
  subscribes :extract, "remote_file[#{cache_dir}/civicrm-#{civicrm_version}-wordpress.zip]", :immediately
end

archive_file "#{cache_dir}/civicrm-#{civicrm_version}-l10n.tar.gz" do
  action :nothing
  destination "/opt/civicrm-#{civicrm_version}/civicrm"
  overwrite true
  owner "wordpress"
  group "wordpress"
  subscribes :extract, "remote_file[#{cache_dir}/civicrm-#{civicrm_version}-l10n.tar.gz]", :immediately
end

execute "/opt/civicrm-#{civicrm_version}/civicrm" do
  action :nothing
  command "rsync --archive --delete --delete-delay --delay-updates /opt/civicrm-#{civicrm_version}/civicrm/ #{civicrm_directory}"
  user "wordpress"
  group "wordpress"
  subscribes :run, "archive_file[#{cache_dir}/civicrm-#{civicrm_version}-wordpress.zip]", :immediately
  subscribes :run, "archive_file[#{cache_dir}/civicrm-#{civicrm_version}-l10n.tar.gz]", :immediately
end

directory "/srv/supporting.openstreetmap.org/wp-content/uploads" do
  owner "www-data"
  group "www-data"
  mode "755"
end

extensions_directory = "/srv/supporting.openstreetmap.org/wp-content/plugins/civicrm-extensions"

directory extensions_directory do
  owner "wordpress"
  group "wordpress"
  mode "755"
end

node[:civicrm][:extensions].each_value do |details|
  if details[:repository]
    git "#{extensions_directory}/#{details[:name]}" do
      action :sync
      repository details[:repository]
      revision details[:revision]
      user "wordpress"
      group "wordpress"
    end
  elsif details[:zip]
    remote_file "#{cache_dir}/#{details[:name]}.zip" do
      source details[:zip]
      owner "root"
      group "root"
      mode "644"
      backup false
    end

    archive_file "#{cache_dir}/#{details[:name]}.zip" do
      action :nothing
      destination "#{extensions_directory}/#{details[:name]}"
      strip_components 1
      owner "wordpress"
      group "wordpress"
      overwrite true
      subscribes :extract, "remote_file[#{cache_dir}/#{details[:name]}.zip]", :immediately
    end
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
  line.gsub!(/%%templateCompileDir%%/, "/srv/supporting.openstreetmap.org/wp-content/uploads/civicrm/templates_c/")
  line.gsub!(/%%baseURL%%/, "http://supporting.openstreetmap.org/")
  line.gsub!(/%%siteKey%%/, site_key)
  line.gsub!(/%%credKeys%%/, cred_keys)
  line.gsub!(/%%signKeys%%/, sign_keys)
  line.gsub!(%r{// *define\('CIVICRM_CMSDIR', '/path/to/install/root/'\);}, "define('CIVICRM_CMSDIR', '/srv/supporting.openstreetmap.org');")
  # Don't recompile smarty templates on every call https://docs.civicrm.org/sysadmin/en/latest/setup/optimizations/#disable-compile-check
  line.gsub!(%r{//  define\('CIVICRM_TEMPLATE_COMPILE_CHECK', FALSE\);}, "define('CIVICRM_TEMPLATE_COMPILE_CHECK', FALSE);")

  line
end

directory "/srv/supporting.openstreetmap.org/wp-content/uploads/civicrm" do
  owner "www-data"
  group "www-data"
  mode "755"
end

file "/srv/supporting.openstreetmap.org/wp-content/uploads/civicrm/civicrm.settings.php" do
  owner "wordpress"
  group "wordpress"
  mode "644"
  content settings
end

file "#{civicrm_directory}/civicrm.settings.php" do
  action :delete
end

systemd_service "osmf-crm-jobs" do
  description "Run CRM jobs"
  exec_start "/usr/bin/php #{civicrm_directory}/civicrm/bin/cli.php -s supporting.openstreetmap.org -u batch -p \"#{passwords['batch']}\" -e Job -a execute"
  user "www-data"
  sandbox :enable_network => true
  memory_deny_write_execute false
  restrict_address_families "AF_UNIX"
  read_write_paths "/srv/supporting.openstreetmap.org/wp-content/uploads/civicrm"
end

systemd_timer "osmf-crm-jobs" do
  description "Run CRM jobs"
  on_boot_sec "15m"
  on_unit_inactive_sec "15m"
end

service "osmf-crm-jobs.timer" do
  action [:enable, :start]
end

template "/etc/cron.daily/osmf-crm-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "750"
  variables :passwords => passwords
end
