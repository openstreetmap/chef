#
# Cookbook:: mediawiki
# Resource:: mediawiki_extension
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

property :extension, :kind_of => String, :name_property => true
property :site, :kind_of => String, :required => true
property :source, :kind_of => String
property :template, :kind_of => String
property :template_cookbook, :kind_of => String, :default => "mediawiki"
property :variables, :kind_of => Hash, :default => {}
property :version, :kind_of => String
property :repository, :kind_of => String
property :tag, :kind_of => String
property :reference, :kind_of => String
property :update_site, :kind_of => [TrueClass, FalseClass], :default => true

action :create do
  if new_resource.source
    remote_directory extension_directory do
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
    extension_repository = new_resource.repository || default_repository
    extension_reference = if new_resource.reference
                            new_resource.reference
                          elsif new_resource.tag
                            "refs/tags/#{new_resource.tag}"
                          else
                            "REL#{extension_version}".tr(".", "_")
                          end

    git extension_directory do
      action :sync
      repository extension_repository
      reference extension_reference
      depth 1
      enable_submodules true
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      ignore_failure extension_repository.start_with?("https://github.com/wikimedia/mediawiki-extensions")
    end
  end

  if new_resource.template
    declare_resource :template, "#{mediawiki_directory}/LocalSettings.d/Ext-#{new_resource.extension}.inc.php" do
      cookbook new_resource.template_cookbook
      source new_resource.template
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode "664"
      variables new_resource.variables
    end
  else
    file "#{mediawiki_directory}/LocalSettings.d/Ext-#{new_resource.extension}.inc.php" do
      content "<?php wfLoadExtension( '#{new_resource.extension}' );\n"
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode "664"
    end
  end

  execute "#{extension_directory}/composer.json" do
    action :nothing
    command "composer update --no-dev"
    cwd mediawiki_directory
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    environment "COMPOSER_HOME" => site_directory
    only_if { ::File.exist?("#{extension_directory}/composer.json") }
    subscribes :run, "git[#{extension_directory}]"
  end
end

action :delete do
  directory extension_directory do
    action :delete
    recursive true
  end

  file "#{mediawiki_directory}/LocalSettings.d/Ext-#{new_resource.extension}.inc.php" do
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

  def extension_directory
    "#{mediawiki_directory}/extensions/#{new_resource.extension}"
  end

  def extension_version
    new_resource.version || node[:mediawiki][:sites][new_resource.site][:version]
  end

  def default_repository
    "https://github.com/wikimedia/mediawiki-extensions-#{new_resource.extension}.git"
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
