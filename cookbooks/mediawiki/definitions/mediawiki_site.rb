#
# Cookbook Name:: web
# Definition:: mediawiki_site
#
# Copyright 2012, OpenStreetMap Foundation
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

define :mediawiki_site, :action => [ :create, :enable ] do
  name = params[:name]

  #/etc/cron.d names cannot contain a dot
  cron_name = name.tr(".", "_")

  aliases = Array(params[:aliases])

  site_directory = params[:directory] || "/srv/#{name}"

  database_params = {
    :host => params[:database_host] || "localhost",
    :name => params[:database_name],
    :username => params[:database_username],
    :password => params[:database_password]
  }

  mediawiki_repository     = "git://github.com/wikimedia/mediawiki-core"
  mediawiki_version        = params[:version] || "1.22"
  mediawiki_reference      = "refs/heads/REL#{mediawiki_version}".tr(".", "_")

  mediawiki = {
    :directory         => "#{site_directory}/w",
    :site              => name,
    :sitename          => params[:sitename] || "OpenStreetMap Wiki",
    :metanamespace     => params[:metanamespace] || "OpenStreetMap",
    :logo              => params[:logo] || "$wgStylePath/common/images/wiki.png",
    :email_contact     => params[:email_contact] || "",
    :email_sender      => params[:email_sender] || "",
    :email_sender_name => params[:email_sender_name] || "MediaWiki Mail",
    :commons           => params[:commons] || TRUE,
    :skin              => params[:skin] || "vector",
    :site_notice       => params[:site_notice] || "",
    :site_readonly     => params[:site_readonly] || FALSE,
    :site_admin_user   => "Admin",
    :site_admin_pw     => params[:admin_password],
    :enable_ssl        => params[:enable_ssl] || FALSE,
    :private_accounts  => params[:private_accounts] || FALSE,
    :private           => params[:private] || FALSE,
    :recaptcha_public  => params[:recaptcha_public_key],
    :recaptcha_private => params[:recaptcha_private_key]
  }

#----------------

  node.set_unless[:mediawiki][:sites][name] = {}
  node.set[:mediawiki][:sites][name][:site_directory] = site_directory
  node.set[:mediawiki][:sites][name][:directory] = mediawiki[:directory]
  node.set[:mediawiki][:sites][name][:version] = mediawiki_version
  node.set_unless[:mediawiki][:sites][name][:wgSecretKey] = random_password(64)

#----------------

  mysql_user "#{database_params[:username]}@localhost" do
    password database_params[:password]
  end

  mysql_database database_params[:name] do
    permissions "#{database_params[:username]}@localhost" => :all
  end

  ruby_block "rename-installer-localsettings" do
    action :nothing
    block do
      ::File.rename("#{mediawiki[:directory]}/LocalSettings.php", "#{mediawiki[:directory]}/LocalSettings-install.php")
    end
  end

  execute "#{mediawiki[:directory]}/maintenance/install.php" do
    action :nothing
    #Use metanamespace as Site Name to ensure correct set namespace
    command "php maintenance/install.php --server '#{name}' --dbtype 'mysql' --dbname '#{database_params[:name]}' --dbuser '#{database_params[:username]}' --dbpass '#{database_params[:password]}' --dbserver '#{database_params[:host]}' --scriptpath /w --pass '#{mediawiki[:site_admin_pw]}' '#{mediawiki[:metanamespace]}' '#{mediawiki[:site_admin_user]}'"
    cwd mediawiki[:directory]
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    not_if do
      File.exist?("#{mediawiki[:directory]}/LocalSettings-install.php")
    end
    notifies :create, 'ruby_block[rename-installer-localsettings]', :immediately
  end

  execute "#{mediawiki[:directory]}/maintenance/update.php" do
    action :nothing
    command "php maintenance/update.php --quick"
    cwd mediawiki[:directory]
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
  end

  directory "#{site_directory}" do
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0775
  end

  directory "#{mediawiki[:directory]}" do
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0775
  end

  git "#{mediawiki[:directory]}" do
    action :sync
    repository mediawiki_repository
    reference mediawiki_reference
    #depth 1
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    notifies :run, resources(:execute => "#{mediawiki[:directory]}/maintenance/install.php"), :immediately
    notifies :run, resources(:execute => "#{mediawiki[:directory]}/maintenance/update.php")
  end

  #Safety catch if git doesn't update but install.php hasn't run
  ruby_block "catch-installer-localsettings-run" do
    block do
      #
    end
    not_if do
      File.exist?("#{mediawiki[:directory]}/LocalSettings-install.php")
    end
    notifies :run, resources(:execute => "#{mediawiki[:directory]}/maintenance/install.php"), :immediately
    action :create
  end

  directory "#{mediawiki[:directory]}/images" do
    owner "www-data"
    group "wiki"
    mode 0775
  end

  directory "#{mediawiki[:directory]}/cache" do
    owner "www-data"
    group "wiki"
    mode 0775
  end

  directory "#{mediawiki[:directory]}/LocalSettings.d" do
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0775
  end

  template "#{mediawiki[:directory]}/LocalSettings.php" do
    cookbook "mediawiki"
    source "LocalSettings.php.erb"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0664
    variables({
      :name => name,
      :database_params => database_params,
      :mediawiki => mediawiki
    })
    notifies :run, resources(:execute => "#{mediawiki[:directory]}/maintenance/update.php")
  end

  template "/etc/cron.d/mediawiki-#{cron_name}" do
    cookbook "mediawiki"
    source "mediawiki.cron.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
      :name => name,
      :directory => site_directory,
      :user => node[:mediawiki][:user]
    })
  end

  template "/etc/cron.daily/mediawiki-#{cron_name}-backup" do
    cookbook "mediawiki"
    source "mediawiki-backup.cron.erb"
    owner "root"
    group "root"
    mode 0700
    variables({
      :name => name,
      :directory => site_directory,
      :database_params => database_params
    })
  end

  #MediaWiki Default Extension

  mediawiki_extension "Cite" do
    site name
    template "mw-ext-Cite.inc.php.erb"
  end

  mediawiki_extension "ConfirmEdit" do
    site name
    template "mw-ext-ConfirmEdit.inc.php.erb"
    variables :public_key => mediawiki[:recaptcha_public],
              :private_key => mediawiki[:recaptcha_private]
  end

  mediawiki_extension "Gadgets" do
    site name
  end

  mediawiki_extension "ImageMap" do
    site name
  end

  mediawiki_extension "InputBox" do
    site name
  end

  mediawiki_extension "Interwiki" do
    site name
  end

  # "LocalisationUpdate" part of Language Extension Bundle, bundled per site

  mediawiki_extension "Nuke" do
    site name
  end

  mediawiki_extension "ParserFunctions" do
    site name
    template "mw-ext-ParserFunctions.inc.php.erb"
  end

  mediawiki_extension "PdfHandler" do
    site name
    template "mw-ext-PdfHandler.inc.php.erb"
  end

  mediawiki_extension "Poem" do
    site name
  end

  mediawiki_extension "Renameuser" do
    site name
  end

  mediawiki_extension "SimpleAntiSpam" do
    site name
  end

  mediawiki_extension "SpamBlacklist" do
    site name
    template "mw-ext-SpamBlacklist.inc.php.erb"
  end

  mediawiki_extension "SyntaxHighlight_GeSHi" do
    site name
  end

  mediawiki_extension "TitleBlacklist" do
    site name
    template "mw-ext-TitleBlacklist.inc.php.erb"
  end

  mediawiki_extension "WikiEditor" do
    site name
  end

  # MediaWiki Language Extension Bundle
  #fixme should automatically resolve tag
  mw_lang_ext_bundle_tag = "2014.09"

  mediawiki_extension "Babel" do
    site name
    template "mw-ext-Babel.inc.php.erb"
    tag mw_lang_ext_bundle_tag
  end

  mediawiki_extension "cldr" do
    site name
    tag mw_lang_ext_bundle_tag
  end

  mediawiki_extension "CleanChanges" do
    site name
    template "mw-ext-CleanChanges.inc.php.erb"
    tag mw_lang_ext_bundle_tag
  end

  mediawiki_extension "LocalisationUpdate" do
    site name
    template "mw-ext-LocalisationUpdate.inc.php.erb"
    tag mw_lang_ext_bundle_tag
  end

  #LocalisationUpdate Update Cron
  #template "/etc/cron.d/mediawiki-#{name}-LocalisationUpdate" do
  #  cookbook "mediawiki"
  #  source "mediawiki-LocalisationUpdate.cron.erb"
  #  owner "root"
  #  group "root"
  #  mode 0755
  #  variables({
  #    :name => name,
  #    :directory => site_directory,
  #    :user => node[:mediawiki][:user]
  #  })
  #end

  #mediawiki_extension "Translate" do
  #  site name
  #  template "mw-ext-Translate.inc.php.erb"
  #  tag mw_lang_ext_bundle_tag
  #end

  mediawiki_extension "UniversalLanguageSelector" do
    site name
    tag mw_lang_ext_bundle_tag
  end

  # Global Extra Mediawiki Extensions

  mediawiki_extension "AntiSpoof" do
    site name
  end

  mediawiki_extension "AbuseFilter" do
    site name
    template "mw-ext-AbuseFilter.inc.php.erb"
  end

  mediawiki_extension "CheckUser" do
    site name
    template "mw-ext-CheckUser.inc.php.erb"
  end

  mediawiki_extension "DismissableSiteNotice" do
    site name
  end

  mediawiki_extension "Elastica" do
    site name
  end

  mediawiki_extension "CirrusSearch" do
    site name
    template "mw-ext-CirrusSearch.inc.php.erb"
  end

  #OSM specifc extensions

  mediawiki_extension "osmtaginfo" do
    site name
    repository "git://github.com/Firefishy/osmtaginfo.git"
    tag "live"
  end
  mediawiki_extension "SimpleMap" do
    site name
    repository "git://github.com/Firefishy/SimpleMap.git"
    tag "live"
  end

  mediawiki_extension "SlippyMap" do
    site name
    repository "git://github.com/Firefishy/SlippyMap.git"
    tag "live"
  end

  cookbook_file "#{site_directory}/cc-wiki.png" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0644
    backup false
  end

  cookbook_file "#{site_directory}/googled06a989d1ccc8364.html" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0644
    backup false
  end

  cookbook_file "#{site_directory}/googlefac54c35e800caab.html" do
    cookbook "mediawiki"
    owner node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0644
    backup false
  end

  apache_site name do
    cookbook "mediawiki"
    template "apache.erb"
    directory site_directory
    variables({
      :aliases => aliases,
      :mediawiki => mediawiki
    })
    notifies :reload, "service[apache2]"
  end

  #Fixme - Needs to run once
  execute "#{mediawiki[:directory]}/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php" do
    action :nothing
    command "php extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php"
    cwd mediawiki[:directory]
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
  end

end
