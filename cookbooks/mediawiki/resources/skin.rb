#
# Cookbook:: mediawiki
# Resource:: mediawiki_skin
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

property :skin, :kind_of => String, :name_property => true
property :site, :kind_of => String, :required => true
property :source, :kind_of => String
property :template, :kind_of => String
property :variables, :kind_of => Hash, :default => {}
property :version, :kind_of => String
property :repository, :kind_of => String
property :revision, :kind_of => String
property :update_site, :kind_of => [TrueClass, FalseClass], :default => true
property :legacy, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  if new_resource.source
    remote_directory skin_directory do
      cookbook "mediawiki"
      source new_resource.source
      owner node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode "755"
      files_owner node[:mediawiki][:user]
      files_group node[:mediawiki][:group]
      files_mode "755"
    end
  else
    skin_repository = new_resource.repository || default_repository
    skin_revision = new_resource.revision || "REL#{skin_version}".tr(".", "_")

    git skin_directory do
      action :sync
      repository skin_repository
      revision skin_revision
      enable_submodules true
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      ignore_failure skin_repository.start_with?("https://github.com/wikimedia/mediawiki-skins")
    end
  end

  if new_resource.template
    declare_resource :template, "#{mediawiki_directory}/LocalSettings.d/Skin-#{new_resource.skin}.inc.php" do
      cookbook "mediawiki"
      source new_resource.template
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode "664"
      variables new_resource.variables
    end
  else
    if new_resource.legacy
      file_content = "<?php require_once('#{skin_directory}/#{new_resource.skin}.php');\n"
      skin_file = "#{skin_directory}/#{new_resource.skin}.php"
    else
      file_content = "<?php wfLoadSkin('#{new_resource.skin}');\n"
      skin_file = "#{skin_directory}/skin.json"
    end

    file "#{mediawiki_directory}/LocalSettings.d/Skin-#{new_resource.skin}.inc.php" do
      content file_content
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode "664"
      only_if { ::File.exist?(skin_file) }
    end
  end
end

action :delete do
  directory skin_directory do
    action :delete
    recursive true
  end

  file "#{mediawiki_directory}/LocalSettings.d/Skin-#{new_resource.skin}.inc.php" do
    action :delete
  end
end

action_class do
  def site_directory
    node[:mediawiki][:sites][new_resource.site][:directory]
  end

  def mediawiki_directory
    "#{site_directory}/w"
  end

  def skin_directory
    "#{mediawiki_directory}/skins/#{new_resource.skin}"
  end

  def skin_version
    new_resource.version || node[:mediawiki][:sites][new_resource.site][:version]
  end

  def default_repository
    "https://github.com/wikimedia/mediawiki-skins-#{new_resource.skin}.git"
  end
end

def after_created
  if update_site
    notifies :update, "mediawiki_site[#{site}]"
  else
    site_directory = node[:mediawiki][:sites][site][:directory]

    notifies :create, "template[#{site_directory}/w/LocalSettings.php]"
    notifies :run, "execute[#{site_directory}/w/maintenance/update.php]"
  end
end
