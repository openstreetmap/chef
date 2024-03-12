#
# Cookbook:: mediawiki
# Resource:: mediawiki_site
#
# Copyright:: 2015, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unified_mode true

default_action :create

property :site, :kind_of => String, :name_property => true
property :aliases, :kind_of => [String, Array]
property :version, :kind_of => String, :default => "1.39"
property :database_name, :kind_of => String, :required => true
property :database_user, :kind_of => String, :required => [:create, :update]
property :database_password, :kind_of => String, :required => [:create, :update]
property :sitename, :kind_of => String, :default => "OpenStreetMap Wiki"
property :metanamespace, :kind_of => String, :default => "OpenStreetMap"
property :logo, :kind_of => String, :default => "$wgStylePath/common/images/wiki.png"
property :email_contact, :kind_of => String, :default => ""
property :email_sender, :kind_of => String, :default => ""
property :email_sender_name, :kind_of => String, :default => "MediaWiki Mail"
property :commons, :kind_of => [TrueClass, FalseClass], :default => true
property :skin, :kind_of => String, :default => "vector"
property :site_notice, :kind_of => [String, TrueClass, FalseClass], :default => false
property :site_readonly, :kind_of => [String, TrueClass, FalseClass], :default => false
property :admin_user, :kind_of => String, :default => "Admin"
property :admin_password, :kind_of => String, :required => [:create]
property :private_accounts, :kind_of => [TrueClass, FalseClass], :default => false
property :private_site, :kind_of => [TrueClass, FalseClass], :default => false
property :hcaptcha_public_key, :kind_of => String, :default => ""
property :hcaptcha_private_key, :kind_of => String, :default => ""
property :extra_file_extensions, :kind_of => [String, Array], :default => []
property :fpm_max_children, :kind_of => Integer, :default => 5
property :fpm_start_servers, :kind_of => Integer, :default => 2
property :fpm_min_spare_servers, :kind_of => Integer, :default => 1
property :fpm_max_spare_servers, :kind_of => Integer, :default => 3
property :fpm_request_terminate_timeout, :kind_of => Integer, :default => 300
property :fpm_prometheus_port, :kind_of => Integer
property :reload_apache, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  node.default[:mediawiki][:sites][new_resource.site] = {
    :directory => site_directory,
    :version => new_resource.version
  }

  mysql_user "#{new_resource.database_user}@localhost" do
    password new_resource.database_password
    reload true
  end

  mysql_database new_resource.database_name do
    permissions "#{new_resource.database_user}@localhost" => :all
  end

  mediawiki_directory = "#{site_directory}/w"

  declare_resource :directory, site_directory do
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "775"
  end

  declare_resource :directory, mediawiki_directory do
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "775"
  end

  git mediawiki_directory do
    action :sync
    repository "https://gerrit.wikimedia.org/r/mediawiki/core.git"
    revision mediawiki_reference
    depth 1
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
  end

  template "#{mediawiki_directory}/composer.local.json" do
    cookbook "mediawiki"
    source "composer.local.json.erb"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "664"
  end

  execute "#{mediawiki_directory}/composer.json" do
    command "composer update --no-dev"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    environment "COMPOSER_HOME" => site_directory
    not_if { ::File.exist?("#{mediawiki_directory}/composer.lock") }
  end

  execute "#{mediawiki_directory}/maintenance/install.php" do
    # Use metanamespace as Site Name to ensure correct set namespace
    command "php maintenance/install.php --server '#{name}' --dbtype 'mysql' --dbname '#{new_resource.database_name}' --dbuser '#{new_resource.database_user}' --dbpass '#{new_resource.database_password}' --dbserver 'localhost' --scriptpath /w --pass '#{new_resource.admin_password}' '#{new_resource.metanamespace}' '#{new_resource.admin_user}'"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    not_if { ::File.exist?("#{mediawiki_directory}/LocalSettings.php") }
  end

  declare_resource :directory, "#{mediawiki_directory}/images" do
    owner "www-data"
    group node[:mediawiki][:group]
    mode "775"
  end

  declare_resource :directory, "#{mediawiki_directory}/cache" do
    owner "www-data"
    group node[:mediawiki][:group]
    mode "775"
  end

  declare_resource :directory, "#{mediawiki_directory}/LocalSettings.d" do
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "775"
  end

  template "#{mediawiki_directory}/LocalSettings.php" do
    cookbook "mediawiki"
    source "LocalSettings.php.erb"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "664"
    variables :name => new_resource.site,
              :directory => mediawiki_directory,
              :database_params => database_params,
              :mediawiki => mediawiki_params,
              :secret_key => secret_key
  end

  service "mediawiki-sitemap@#{new_resource.site}.timer" do
    action [:enable, :start]
    only_if { ::File.exist?("#{mediawiki_directory}/LocalSettings.php") }
  end

  service "mediawiki-jobs@#{new_resource.site}.timer" do
    action [:enable, :start]
    only_if { ::File.exist?("#{mediawiki_directory}/LocalSettings.php") }
  end

  service "mediawiki-email-jobs@#{new_resource.site}.timer" do
    action [:enable, :start]
    only_if { ::File.exist?("#{mediawiki_directory}/LocalSettings.php") }
  end

  template "/etc/cron.daily/mediawiki-#{cron_name}-backup" do
    cookbook "mediawiki"
    source "mediawiki-backup.cron.erb"
    owner "root"
    group "root"
    mode "700"
    variables :name => new_resource.site,
              :directory => site_directory,
              :database_params => database_params
    only_if { ::File.exist?("#{mediawiki_directory}/LocalSettings.php") }
  end

  # MobileFrontend extension is required by MinervaNeue skin
  mediawiki_extension "MobileFrontend" do
    site new_resource.site
    template "mw-ext-MobileFrontend.inc.php.erb"
    update_site false
  end

  # MobileFrontend extension is required by MinervaNeue skin
  mediawiki_skin "MinervaNeue" do
    site new_resource.site
    update_site false
    legacy false
  end

  mediawiki_skin "CologneBlue" do
    site new_resource.site
    update_site false
    legacy false
  end

  mediawiki_skin "Modern" do
    site new_resource.site
    update_site false
    legacy false
  end

  mediawiki_skin "MonoBook" do
    site new_resource.site
    update_site false
    legacy false
  end

  mediawiki_skin "Vector" do
    site new_resource.site
    update_site false
    legacy false
  end

  mediawiki_extension "Cite" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "CiteThisPage" do
    site new_resource.site
    update_site false
  end

  if new_resource.private_accounts || new_resource.private_site
    mediawiki_extension "ConfirmEdit" do
      site new_resource.site
      update_site false
      action :delete
    end
  else
    mediawiki_extension "ConfirmEdit" do
      site new_resource.site
      template "mw-ext-ConfirmEdit.inc.php.erb"
      variables :public_key => new_resource.hcaptcha_public_key,
                :private_key => new_resource.hcaptcha_private_key
      update_site false
    end
  end

  mediawiki_extension "Gadgets" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "ImageMap" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "InputBox" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "Interwiki" do
    site new_resource.site
    template "mw-ext-Interwiki.inc.php.erb"
    update_site false
  end

  mediawiki_extension "Nuke" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "ParserFunctions" do
    site new_resource.site
    template "mw-ext-ParserFunctions.inc.php.erb"
    update_site false
  end

  mediawiki_extension "PdfHandler" do
    site new_resource.site
    template "mw-ext-PdfHandler.inc.php.erb"
    update_site false
  end

  mediawiki_extension "Poem" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "Renameuser" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "SimpleAntiSpam" do
    site new_resource.site
    update_site false
    action :delete
  end

  mediawiki_extension "SpamBlacklist" do
    site new_resource.site
    template "mw-ext-SpamBlacklist.inc.php.erb"
    update_site false
  end

  mediawiki_extension "SyntaxHighlight_GeSHi" do
    site new_resource.site
    template "mw-ext-SyntaxHighlight.inc.php.erb"
    update_site false
  end

  mediawiki_extension "TitleBlacklist" do
    site new_resource.site
    template "mw-ext-TitleBlacklist.inc.php.erb"
    update_site false
  end

  mediawiki_extension "WikiEditor" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "Babel" do
    site new_resource.site
    template "mw-ext-Babel.inc.php.erb"
    update_site false
  end

  mediawiki_extension "CategoryTree" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "cldr" do
    site new_resource.site
    template "mw-ext-cldr.inc.php.erb"
    update_site false
  end

  mediawiki_extension "CleanChanges" do
    site new_resource.site
    template "mw-ext-CleanChanges.inc.php.erb"
    update_site false
  end

  # Extension has been archived: https://www.mediawiki.org/wiki/Extension:LocalisationUpdate
  mediawiki_extension "LocalisationUpdate" do
    site new_resource.site
    action :delete
  end

  # mediawiki_extension "Translate" do
  #   site new_resource.site
  #   template "mw-ext-Translate.inc.php.erb"
  #   update_site false
  # end

  mediawiki_extension "UniversalLanguageSelector" do
    site new_resource.site
    template "mw-ext-UniversalLanguageSelector.inc.php.erb"
    update_site false
  end

  mediawiki_extension "AntiSpoof" do
    site new_resource.site
    template "mw-ext-AntiSpoof.inc.php.erb"
    update_site false
  end

  mediawiki_extension "AbuseFilter" do
    site new_resource.site
    template "mw-ext-AbuseFilter.inc.php.erb"
    update_site false
  end

  mediawiki_extension "CheckUser" do
    site new_resource.site
    template "mw-ext-CheckUser.inc.php.erb"
    update_site false
  end

  mediawiki_extension "DismissableSiteNotice" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "Elastica" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "CirrusSearch" do
    site new_resource.site
    template "mw-ext-CirrusSearch.inc.php.erb"
    update_site false
  end

  mediawiki_extension "osmtaginfo" do
    site new_resource.site
    repository "https://github.com/openstreetmap/osmtaginfo.git"
    tag "live"
    update_site false
  end

  mediawiki_extension "OSMCALWikiWidget" do
    site new_resource.site
    repository "https://github.com/thomersch/OSMCALWikiWidget.git"
    tag "live"
    update_site false
  end

  mediawiki_extension "DisableAccount" do
    site new_resource.site
    template "mw-ext-DisableAccount.inc.php.erb"
    update_site false
  end

  mediawiki_extension "VisualEditor" do
    site new_resource.site
    template "mw-ext-VisualEditor.inc.php.erb"
    variables :version => new_resource.version
    update_site false
  end

  mediawiki_extension "TemplateData" do
    site new_resource.site
    update_site false
  end

  if new_resource.commons
    mediawiki_extension "QuickInstantCommons" do
      site new_resource.site
      update_site false
    end
  else
    mediawiki_extension "QuickInstantCommons" do
      site new_resource.site
      update_site false
      action :delete
    end
  end

  cookbook_file "#{site_directory}/cc-wiki.png" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "644"
    backup false
  end

  cookbook_file "#{site_directory}/googled06a989d1ccc8364.html" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "644"
    backup false
  end

  cookbook_file "#{site_directory}/googlefac54c35e800caab.html" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "644"
    backup false
  end

  ssl_certificate new_resource.site do
    domains [new_resource.site] + Array(new_resource.aliases)
  end

  php_fpm new_resource.site do
    pm_max_children new_resource.fpm_max_children
    pm_start_servers new_resource.fpm_start_servers
    pm_min_spare_servers new_resource.fpm_min_spare_servers
    pm_max_spare_servers new_resource.fpm_max_spare_servers
    request_terminate_timeout new_resource.fpm_request_terminate_timeout
    php_admin_values "open_basedir" => "#{site_directory}/:/usr/share/php/:/dev/null:/tmp/"
    php_values "memory_limit" => "500M",
               "max_execution_time" => "240",
               "upload_max_filesize" => "70M",
               "post_max_size" => "100M"
    prometheus_port new_resource.fpm_prometheus_port
  end

  apache_site new_resource.site do
    cookbook "mediawiki"
    template "apache.erb"
    directory site_directory
    variables :aliases => Array(new_resource.aliases),
              :private_site => new_resource.private_site
    reload_apache false
  end

  # FIXME: needs to run one
  execute "#{mediawiki_directory}/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php" do
    action :nothing
    command "php extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
  end
end

action :update do
  mediawiki_directory = "#{site_directory}/w"

  execute "#{mediawiki_directory}/composer.json" do
    command "composer update --no-dev"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    environment "COMPOSER_HOME" => site_directory
  end

  template "#{mediawiki_directory}/LocalSettings.php" do
    cookbook "mediawiki"
    source "LocalSettings.php.erb"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "664"
    variables :name => new_resource.site,
              :directory => mediawiki_directory,
              :database_params => database_params,
              :mediawiki => mediawiki_params,
              :secret_key => secret_key
  end

  execute "#{mediawiki_directory}/maintenance/update.php" do
    action :run
    command "php maintenance/update.php --quick"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    timeout 86400
  end
end

action :delete do
  apache_site new_resource.site do
    action :delete
    reload_apache false
  end

  declare_resource :directory, site_directory do
    action :delete
    recursive true
  end

  mysql_database new_resource.database_name do
    action :drop
  end

  mysql_user "#{new_resource.database_user}@localhost" do
    action :drop
  end
end

action_class do
  include OpenStreetMap::Mixin::PersistentToken

  def site_directory
    "/srv/#{new_resource.site}"
  end

  def mediawiki_reference
    shell_out!("git", "ls-remote", "--refs", "--sort=-version:refname",
               "https://gerrit.wikimedia.org/r/mediawiki/core.git",
               "refs/tags/#{new_resource.version}.*")
      .stdout
      .split("\n")
      .first
      .split("/")
      .last
  end

  def cron_name
    new_resource.site.tr(".", "_")
  end

  def database_params
    {
      :host => "localhost",
      :name => new_resource.database_name,
      :username => new_resource.database_user,
      :password => new_resource.database_password
    }
  end

  def mediawiki_params
    {
      :sitename => new_resource.sitename,
      :metanamespace => new_resource.metanamespace,
      :logo => new_resource.logo,
      :email_contact => new_resource.email_contact,
      :email_sender => new_resource.email_sender,
      :email_sender_name => new_resource.email_sender_name,
      :commons => new_resource.commons,
      :skin => new_resource.skin,
      :site_notice => new_resource.site_notice,
      :site_readonly => new_resource.site_readonly,
      :extra_file_extensions => new_resource.extra_file_extensions,
      :private_accounts => new_resource.private_accounts,
      :private_site => new_resource.private_site
    }
  end

  def secret_key
    persistent_token("mediawiki", new_resource.site, "wgSecretKey")
  end
end

def after_created
  notifies :update, "mediawiki_site[#{site}]"
  notifies :reload, "service[apache2]" if reload_apache
end
