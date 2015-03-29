#
# Cookbook Name:: mediawiki
# Provider:: mediawiki_extension
#
# Copyright 2015, OpenStreetMap Foundation
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

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if new_resource.source
    remote_directory extension_directory do
      cookbook "mediawiki"
      source new_resource.source
      owner node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode 0755
      files_owner node[:mediawiki][:user]
      files_group node[:mediawiki][:group]
      files_mode 0755
    end
  else
    extension_repository = new_resource.repository || default_repository
    extension_reference = if new_resource.tag
                            "refs/tags/#{new_resource.tag}"
                          else
                            "refs/heads/REL#{extension_version}".tr(".", "_")
                          end

    git extension_directory do
      action :sync
      repository extension_repository
      reference extension_reference
      enable_submodules true
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      ignore_failure extension_repository.start_with?("git://github.com/wikimedia/mediawiki-extensions")
    end
  end

  if new_resource.template # ~FC023
    template "#{mediawiki_directory}/LocalSettings.d/Ext-#{new_resource.name}.inc.php" do
      cookbook "mediawiki"
      source new_resource.template
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode 0664
      variables new_resource.variables
    end
  else
    extension_script = "#{extension_directory}/#{new_resource.name}.php"

    file "#{mediawiki_directory}/LocalSettings.d/Ext-#{new_resource.name}.inc.php" do
      action :create
      content "<?php require_once('#{extension_script}');\n"
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode 0664
      only_if { ::File.exist?(extension_script) }
    end
  end
end

action :delete do
  directory extension_directory do
    action :delete
    recursive true
  end

  file "#{mediawiki_directory}/LocalSettings.d/Ext-#{new_resource.name}.inc.php" do
    action :delete
  end
end

private

def site_directory
  node[:mediawiki][:sites][new_resource.site][:directory]
end

def mediawiki_directory
  "#{site_directory}/w"
end

def extension_directory
  "#{mediawiki_directory}/extensions/#{new_resource.name}"
end

def extension_version
  new_resource.version || node[:mediawiki][:sites][new_resource.site][:version]
end

def default_repository
  "git://github.com/wikimedia/mediawiki-extensions-#{new_resource.name}.git"
end
