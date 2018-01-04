#
# Cookbook Name:: mediawiki
# Resource:: mediawiki_site
#
# Copyright 2015, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :create

property :site, :kind_of => String, :name_attribute => true
property :aliases, :kind_of => [String, Array]
property :directory, :kind_of => String
property :version, :kind_of => String, :default => "1.29"
property :database_name, :kind_of => String, :required => true
property :database_user, :kind_of => String, :required => true
property :database_password, :kind_of => String, :required => true
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
property :admin_password, :kind_of => String, :required => true
property :ssl_enabled, :kind_of => [TrueClass, FalseClass], :default => false
property :private_accounts, :kind_of => [TrueClass, FalseClass], :default => false
property :private, :kind_of => [TrueClass, FalseClass], :default => false
property :recaptcha_public_key, :kind_of => String
property :recaptcha_private_key, :kind_of => String
property :extra_file_extensions, :kind_of => [String, Array], :default => []
property :reload_apache, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  node.normal_unless[:mediawiki][:sites][new_resource.site] = {}

  node.normal[:mediawiki][:sites][new_resource.site][:directory] = site_directory
  node.normal[:mediawiki][:sites][new_resource.site][:version] = new_resource.version

  node.normal_unless[:mediawiki][:sites][new_resource.site][:wgSecretKey] = SecureRandom.base64(48)

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
    mode 0o775
  end

  declare_resource :directory, mediawiki_directory do
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0o775
  end

  mediawiki_reference = "REL#{new_resource.version}".tr(".", "_")

  git "#{mediawiki_directory}/vendor" do
    action :nothing
    repository "https://gerrit.wikimedia.org/r/p/mediawiki/vendor.git"
    revision mediawiki_reference
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
  end

  git mediawiki_directory do
    action :sync
    repository "https://gerrit.wikimedia.org/r/p/mediawiki/core.git"
    revision mediawiki_reference
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    notifies :sync, "git[#{mediawiki_directory}/vendor]", :immediately
    notifies :run, "execute[#{mediawiki_directory}/maintenance/install.php]", :immediately
    notifies :run, "execute[#{mediawiki_directory}/maintenance/update.php]"
  end

  # Safety catch if git doesn't update but install.php hasn't run
  ruby_block "catch-installer-localsettings-run" do
    action :run
    block do
      #
    end
    not_if do
      ::File.exist?("#{mediawiki_directory}/LocalSettings-install.php")
    end
    notifies :run, "execute[#{mediawiki_directory}/maintenance/install.php]", :immediately
  end

  declare_resource :directory, "#{mediawiki_directory}/images" do
    owner "www-data"
    group node[:mediawiki][:group]
    mode 0o775
  end

  declare_resource :directory, "#{mediawiki_directory}/cache" do
    owner "www-data"
    group node[:mediawiki][:group]
    mode 0o775
  end

  declare_resource :directory, "#{mediawiki_directory}/LocalSettings.d" do
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0o775
  end

  template "#{mediawiki_directory}/LocalSettings.php" do
    cookbook "mediawiki"
    source "LocalSettings.php.erb"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0o664
    variables :name => new_resource.site,
              :directory => mediawiki_directory,
              :database_params => database_params,
              :mediawiki => mediawiki_params
    notifies :run, "execute[#{mediawiki_directory}/maintenance/update.php]"
  end

  template "/etc/cron.d/mediawiki-#{cron_name}" do
    cookbook "mediawiki"
    source "mediawiki.cron.erb"
    owner "root"
    group "root"
    mode 0o644
    variables :name => new_resource.site, :directory => site_directory,
              :user => node[:mediawiki][:user]
  end

  template "/etc/cron.daily/mediawiki-#{cron_name}-backup" do
    cookbook "mediawiki"
    source "mediawiki-backup.cron.erb"
    owner "root"
    group "root"
    mode 0o700
    variables :name => new_resource.site,
              :directory => site_directory,
              :database_params => database_params
  end

  mediawiki_skin "CologneBlue" do # ~FC005
    site new_resource.site
    update_site false
  end

  mediawiki_skin "Modern" do
    site new_resource.site
    update_site false
  end

  mediawiki_skin "MonoBook" do
    site new_resource.site
    update_site false
  end

  mediawiki_skin "Vector" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "Cite" do
    site new_resource.site
    update_site false
  end

  mediawiki_extension "CiteThisPage" do
    site new_resource.site
    update_site false
  end

  if new_resource.private_accounts || new_resource.private
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

  # MediaWiki Language Extension Bundle
  # FIXME: should automatically resolve tag
  mw_lang_ext_bundle_tag = "2017.01"

  mediawiki_extension "Babel" do
    site new_resource.site
    template "mw-ext-Babel.inc.php.erb"
    # tag mw_lang_ext_bundle_tag
    tag mw_lang_ext_bundle_tag
    update_site false
  end

  mediawiki_extension "cldr" do
    site new_resource.site
    template "mw-ext-cldr.inc.php.erb"
    tag mw_lang_ext_bundle_tag
    update_site false
  end

  mediawiki_extension "CleanChanges" do
    site new_resource.site
    template "mw-ext-CleanChanges.inc.php.erb"
    tag mw_lang_ext_bundle_tag
    update_site false
  end

  mediawiki_extension "LocalisationUpdate" do
    site new_resource.site
    template "mw-ext-LocalisationUpdate.inc.php.erb"
    tag mw_lang_ext_bundle_tag
    update_site false
  end

  # LocalisationUpdate Update Cron
  # template "/etc/cron.d/mediawiki-#{name}-LocalisationUpdate" do
  #   cookbook "mediawiki"
  #   source "mediawiki-LocalisationUpdate.cron.erb"
  #   owner "root"
  #   group "root"
  #   mode 0755
  #   variables :name => name, :directory => site_directory, :user => node[:mediawiki][:user]
  # end

  # mediawiki_extension "Translate" do
  #   site new_resource.site
  #   template "mw-ext-Translate.inc.php.erb"
  #   tag mw_lang_ext_bundle_tag
  #   update_site false
  # end

  mediawiki_extension "UniversalLanguageSelector" do
    site new_resource.site
    tag mw_lang_ext_bundle_tag
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
    repository "git://github.com/Firefishy/osmtaginfo.git"
    tag "live"
    update_site false
  end

  mediawiki_extension "SimpleMap" do
    site new_resource.site
    template "mw-ext-SimpleMap.inc.php.erb"
    repository "git://github.com/Firefishy/SimpleMap.git"
    tag "live"
    update_site false
  end

  mediawiki_extension "SlippyMap" do
    site new_resource.site
    template "mw-ext-SlippyMap.inc.php.erb"
    repository "git://github.com/Firefishy/SlippyMap.git"
    tag "live"
    update_site false
  end

  mediawiki_extension "Mantle" do
    site new_resource.site
    update_site false
    action :delete
  end

  mediawiki_extension "MobileFrontend" do
    site new_resource.site
    template "mw-ext-MobileFrontend.inc.php.erb"
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
    update_site false
  end

  cookbook_file "#{site_directory}/cc-wiki.png" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0o644
    backup false
  end

  cookbook_file "#{site_directory}/googled06a989d1ccc8364.html" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0o644
    backup false
  end

  cookbook_file "#{site_directory}/googlefac54c35e800caab.html" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0o644
    backup false
  end

  ssl_certificate new_resource.site do
    domains [new_resource.site] + Array(new_resource.aliases)
    only_if { new_resource.ssl_enabled }
  end

  apache_site new_resource.site do
    cookbook "mediawiki"
    template "apache.erb"
    directory site_directory
    variables :aliases => Array(new_resource.aliases),
              :private => new_resource.private,
              :ssl_enabled => new_resource.ssl_enabled
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
    mode 0o664
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
      :ssl_enabled => new_resource.ssl_enabled,
      :extra_file_extensions => new_resource.extra_file_extensions,
      :private_accounts => new_resource.private_accounts,
      :private => new_resource.private
    }
  end
end

def after_created
  notifies :reload, "service[apache2]" if reload_apache
end
