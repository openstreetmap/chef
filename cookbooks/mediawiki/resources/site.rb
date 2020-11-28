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

default_action :create

property :site, :kind_of => String, :name_property => true
property :aliases, :kind_of => [String, Array]
property :directory, :kind_of => String
property :version, :kind_of => String, :default => "1.35"
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
property :recaptcha_public_key, :kind_of => String
property :recaptcha_private_key, :kind_of => String
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

  secret_key = persistent_token("mediawiki", new_resource.site, "wgSecretKey")

  mysql_user "#{new_resource.database_user}@localhost" do
    password new_resource.database_password
  end

  mysql_database new_resource.database_name do
    permissions "#{new_resource.database_user}@localhost" => :all
  end

  mediawiki_directory = "#{site_directory}/w"

  ruby_block "rename-installer-localsettings" do
    action :nothing
    block do
      ::File.rename("#{mediawiki_directory}/LocalSettings.php", "#{mediawiki_directory}/LocalSettings-install.php")
    end
  end

  execute "#{mediawiki_directory}/maintenance/install.php" do
    action :nothing
    # Use metanamespace as Site Name to ensure correct set namespace
    command "php maintenance/install.php --server '#{name}' --dbtype 'mysql' --dbname '#{new_resource.database_name}' --dbuser '#{new_resource.database_user}' --dbpass '#{new_resource.database_password}' --dbserver 'localhost' --scriptpath /w --pass '#{new_resource.admin_password}' '#{new_resource.metanamespace}' '#{new_resource.admin_user}'"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    not_if do
      ::File.exist?("#{mediawiki_directory}/LocalSettings-install.php")
    end
    notifies :run, "ruby_block[rename-installer-localsettings]", :immediately
  end

  execute "#{mediawiki_directory}/maintenance/update.php" do
    action :nothing
    command "php maintenance/update.php --quick"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
  end

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

  mediawiki_reference = "REL#{new_resource.version}".tr(".", "_")

  git mediawiki_directory do
    action :sync
    repository "https://gerrit.wikimedia.org/r/mediawiki/core.git"
    revision mediawiki_reference
    depth 1
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    notifies :run, "execute[#{mediawiki_directory}/composer.json]", :immediately
    notifies :run, "execute[#{mediawiki_directory}/maintenance/install.php]", :immediately
    notifies :run, "execute[#{mediawiki_directory}/maintenance/update.php]"
  end

  execute "#{mediawiki_directory}/composer.json" do
    action :nothing
    command "composer update --no-dev"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    environment "COMPOSER_HOME" => site_directory
  end

  template "#{mediawiki_directory}/composer.local.json" do
    cookbook "mediawiki"
    source "composer.local.json.erb"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "664"
  end

  # Safety catch if git doesn't update but install.php hasn't run
  ruby_block "catch-installer-localsettings-run" do
    action :run
    block do
    end
    not_if do
      ::File.exist?("#{mediawiki_directory}/LocalSettings-install.php")
    end
    notifies :run, "execute[#{mediawiki_directory}/maintenance/install.php]", :immediately
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
    notifies :run, "execute[#{mediawiki_directory}/maintenance/update.php]"
  end

  cron_d "mediawiki-#{cron_name}-sitemap" do
    comment "Generate sitemap.xml daily"
    minute "30"
    hour "0"
    user node[:mediawiki][:user]
    command "/usr/bin/nice /usr/bin/php -d memory_limit=2048M -d error_reporting=22517 #{site_directory}/w/maintenance/generateSitemap.php --server=https://#{new_resource.site} --urlpath=https://#{new_resource.site}/ --fspath=#{site_directory} --quiet --skip-redirects"
  end

  cron_d "mediawiki-#{cron_name}-jobs" do
    comment "Run mediawiki jobs"
    minute "*/3"
    user node[:mediawiki][:user]
    command "/usr/bin/nice /usr/bin/php -d memory_limit=2048M -d error_reporting=22517 #{site_directory}/w/maintenance/runJobs.php --server=https://#{new_resource.site} --maxtime=160 --memory-limit=2048M --procs=8 --quiet"
  end

  cron_d "mediawiki-#{cron_name}-email-jobs" do
    comment "Run mediawiki email jobs"
    user node[:mediawiki][:user]
    command "/usr/bin/nice /usr/bin/php -d memory_limit=2048M -d error_reporting=22517 #{site_directory}/w/maintenance/runJobs.php --server=https://#{new_resource.site} --maxtime=30 --type=enotifNotify --memory-limit=2048M --procs=4 --quiet"
  end

  cron_d "mediawiki-#{cron_name}-refresh-links" do
    comment "Run mediawiki refresh links table weekly"
    minute "5"
    hour "0"
    weekday "0"
    user node[:mediawiki][:user]
    command "/usr/bin/nice /usr/bin/php -d memory_limit=2048M -d error_reporting=22517 #{site_directory}/w/maintenance/refreshLinks.php --server=https://#{new_resource.site} --memory-limit=2048M --quiet"
  end

  cron_d "mediawiki-#{cron_name}-cleanup-gs" do
    comment "Clean up imagemagick garbage"
    minute "10"
    hour "2"
    user node[:mediawiki][:user]
    command "/usr/bin/find /tmp/ -maxdepth 1 -type f -user www-data -mmin +90 -name 'gs_*' -delete"
  end

  cron_d "mediawiki-#{cron_name}-cleanup-magick" do
    comment "Clean up imagemagick garbage"
    minute "20"
    hour "2"
    user node[:mediawiki][:user]
    command "/usr/bin/find /tmp/ -maxdepth 1 -type f -user www-data -mmin +90 -name 'magick-*' -delete"
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
  end

  # MobileFrontend extension is required by MinervaNeue skin
  mediawiki_extension "MobileFrontend" do
    site new_resource.site
    template "mw-ext-MobileFrontend.inc.php.erb"
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
      variables :public_key => new_resource.recaptcha_public_key,
                :private_key => new_resource.recaptcha_private_key
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

  mediawiki_extension "LocalisationUpdate" do
    site new_resource.site
    template "mw-ext-LocalisationUpdate.inc.php.erb"
    update_site false
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
    template "mw-ext-osmtaginfo.inc.php.erb"
    repository "https://github.com/Firefishy/osmtaginfo.git"
    tag "live"
    update_site false
  end

  mediawiki_extension "OSMCALWikiWidget" do
    site new_resource.site
    repository "https://github.com/thomersch/OSMCALWikiWidget.git"
    tag "live"
    update_site false
  end

  mediawiki_extension "SimpleMap" do
    site new_resource.site
    template "mw-ext-SimpleMap.inc.php.erb"
    repository "https://github.com/Firefishy/SimpleMap.git"
    tag "live"
    update_site false
  end

  mediawiki_extension "SlippyMap" do
    site new_resource.site
    update_site false
    action :delete
  end

  mediawiki_extension "Mantle" do
    site new_resource.site
    update_site false
    action :delete
  end

  mediawiki_extension "DisableAccount" do
    site new_resource.site
    template "mw-ext-DisableAccount.inc.php.erb"
    update_site false
  end

  mediawiki_extension "VisualEditor" do
    site new_resource.site
    template "mw-ext-VisualEditor.inc.php.erb"
    update_site false
  end

  mediawiki_extension "TemplateData" do
    site new_resource.site
    update_site false
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

  template "#{mediawiki_directory}/LocalSettings.php" do
    cookbook "mediawiki"
    source "LocalSettings.php.erb"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode "664"
    variables :name => new_resource.site,
              :directory => mediawiki_directory,
              :database_params => database_params,
              :mediawiki => mediawiki_params
    notifies :run, "execute[#{mediawiki_directory}/maintenance/update.php]"
  end

  execute "#{mediawiki_directory}/maintenance/update.php" do
    action :run
    command "php maintenance/update.php --quick"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
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
  include Chef::Mixin::PersistentToken

  def site_directory
    new_resource.directory || "/srv/#{new_resource.site}"
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
end

def after_created
  notifies :reload, "service[apache2]" if reload_apache
end
