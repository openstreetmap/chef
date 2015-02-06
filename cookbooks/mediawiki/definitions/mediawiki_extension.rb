#
# Cookbook Name:: mediawiki
# Definition:: mediawiki_extension
#
# Copyright 2013, OpenStreetMap Foundation
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

define :mediawiki_extension, :action => [:enable], :variables => {} do
  name = params[:name]
  site = params[:site]
  mediawiki_directory = node[:mediawiki][:sites][site][:directory]
  extension_directory = "#{mediawiki_directory}/extensions/#{name}"
  source = params[:source]
  template = params[:template]
  template_variables = params[:variables]

  if source
    remote_directory extension_directory do
      cookbook "mediawiki"
      source source
      owner node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode 0755
      files_owner node[:mediawiki][:user]
      files_group node[:mediawiki][:group]
      files_mode 0755
    end
  else
    repository = params[:repository] || "git://github.com/wikimedia/mediawiki-extensions-#{name}.git"
    version = params[:version] ||  node[:mediawiki][:sites][site][:version]
    tag =  params[:tag]
    if tag
      reference  = "refs/tags/#{tag}"
    else
      reference  = "refs/heads/REL#{version}".tr(".", "_")
    end

    git extension_directory do
      action :sync
      repository repository
      reference reference
      # depth 1
      enable_submodules true
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      ignore_failure repository.start_with?("git://github.com/wikimedia/mediawiki-extensions")
      notifies :run, "execute[#{mediawiki_directory}/maintenance/update.php]"
    end
  end

  if template # ~FC023
    template "#{mediawiki_directory}/LocalSettings.d/Ext-#{name}.inc.php" do
      cookbook "mediawiki"
      source template
      user node[:mediawiki][:user]
      group node[:mediawiki][:group]
      mode 0664
      variables template_variables
      notifies :create, "template[#{mediawiki_directory}/LocalSettings.php]"
    end
  end

  file "#{mediawiki_directory}/LocalSettings.d/Ext-#{name}.inc.php" do
    action :create_if_missing
    user node[:mediawiki][:user]
    group node[:mediawiki][:group]
    mode 0664
    content "<?php require_once('#{extension_directory}/#{name}.php');\n"
    only_if { File.exist?("#{extension_directory}/#{name}.php") }
    notifies :create, "template[#{mediawiki_directory}/LocalSettings.php]"
  end
end
