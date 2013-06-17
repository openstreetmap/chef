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

include_recipe "drupal"
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

drupal_site "crm.osmfoundation.org" do
  title "CiviCRM"
  database_name "civicrm"
  database_username "civicrm"
  database_password database_password
  admin_password admin_password
end

directory "/usr/local/share/civicrm" do
  owner "root"
  group "root"
  mode "0755"
end

civicrm_version = node[:civicrm][:version]
civicrm_directory = "/usr/local/share/civicrm/#{civicrm_version}"

subversion civicrm_directory do
  action :export
  repository "http://svn.civicrm.org/civicrm/tags/tarballs/#{node[:civicrm][:version]}"
  user "root"
  group "root"
end

link "/usr/share/drupal7/sites/all/modules/civicrm" do
  to "/usr/local/share/civicrm/#{node[:civicrm][:version]}"
end

directory "/data/crm.osmfoundation.org/civicrm" do
  owner "www-data"
  group "www-data"
  mode "0775"
end

ruby_block "#{civicrm_directory}/civicrm.settings.php" do
  block do
    out = File.new("#{civicrm_directory}/civicrm.settings.php", "w")

    File.foreach("#{civicrm_directory}/templates/CRM/common/civicrm.settings.php.tpl") do |line|
      line.gsub!(/%%cms%%/, "Drupal")
      line.gsub!(/%%CMSdbUser%%/, "civicrm")
      line.gsub!(/%%CMSdbPass%%/, database_password)
      line.gsub!(/%%CMSdbHost%%/, "localhost")
      line.gsub!(/%%CMSdbName%%/, "civicrm")
      line.gsub!(/%%dbUser%%/, "civicrm")
      line.gsub!(/%%dbPass%%/, database_password)
      line.gsub!(/%%dbHost%%/, "localhost")
      line.gsub!(/%%dbName%%/, "civicrm")
      line.gsub!(/%%crmRoot%%/, "/usr/share/drupal7/sites/all/modules/civicrm")
      line.gsub!(/%%templateCompileDir%%/, "/data/crm.osmfoundation.org/civicrm")
      line.gsub!(/%%baseURL%%/, "http://crm.osmfoundation.org/")
      line.gsub!(/%%siteKey%%/, site_key)

      out.print(line)
    end

    out.close
  end

  not_if do
    File.exist?("#{civicrm_directory}/civicrm.settings.php") and
    File.mtime("#{civicrm_directory}/civicrm.settings.php") >= File.mtime("#{civicrm_directory}/templates/CRM/common/civicrm.settings.php.tpl")
  end
end

link "/etc/drupal/7/sites/crm.osmfoundation.org/civicrm.settings.php" do
  to "#{civicrm_directory}/civicrm.settings.php"
end

template "#{civicrm_directory}/settings_location.php" do
  source "settings_location.php.erb"
  owner "root"
  group "root"
  mode "0644"
end

execute "civicrm-load-acl" do
  action :nothing
  command "mysql --user=civicrm --password=#{database_password} civicrm < sql/civicrm_acl.mysql"
  cwd "/usr/share/drupal7/sites/all/modules/civicrm"
  user "root"
  group "root"
end

execute "civicrm-load-data" do
  action :nothing
  command "mysql --user=civicrm --password=#{database_password} civicrm < sql/civicrm_data.mysql"
  cwd "/usr/share/drupal7/sites/all/modules/civicrm"
  user "root"
  group "root"
  notifies :run, resources(:execute => "civicrm-load-acl")
end

execute "civicrm-load" do
  action :nothing
  command "mysql --user=civicrm --password=#{database_password} civicrm < sql/civicrm.mysql"
  cwd "/usr/share/drupal7/sites/all/modules/civicrm"
  user "root"
  group "root"
  notifies :run, resources(:execute => "civicrm-load-data")
end

execute "civicrm-gencode" do
  command "php GenCode.php"
  cwd "#{civicrm_directory}/xml"
  user "root"
  group "root"
  creates "#{civicrm_directory}/civicrm-version.php"
  notifies :run, resources(:execute => "civicrm-load")
end

directory "/data/crm.osmfoundation.org/civicrm/en_US" do
  owner "www-data"
  group "www-data"
  mode "0775"
end

directory "/data/crm.osmfoundation.org/civicrm/en_US/ConfigAndLog" do
  owner "www-data"
  group "www-data"
  mode "0775"
end
