#
# Cookbook Name:: wordpress
# Provider:: wordpress_theme
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
    remote_directory theme_directory do
      cookbook "wordpress"
      source new_resource.source
      owner node[:wordpress][:user]
      group node[:wordpress][:group]
      mode 0o755
      files_owner node[:wordpress][:user]
      files_group node[:wordpress][:group]
      files_mode 0o644
    end
  else
    theme_repository = new_resource.repository || default_repository

    if theme_repository.end_with?(".git")
      git theme_directory do
        action :sync
        repository theme_repository
        revision new_resource.revision
        user node[:wordpress][:user]
        group node[:wordpress][:group]
      end
    else
      subversion theme_directory do
        action :sync
        repository theme_repository
        user node[:wordpress][:user]
        group node[:wordpress][:group]
        ignore_failure theme_repository.start_with?("http://themes.svn.wordpress.org/")
      end
    end
  end
end

action :delete do
  directory theme_directory do
    action :delete
    recursive true
  end
end

private

def site_directory
  node[:wordpress][:sites][new_resource.site][:directory]
end

def theme_directory
  "#{site_directory}/wp-content/themes/#{new_resource.name}"
end

def default_repository
  "http://themes.svn.wordpress.org/#{new_resource.name}/#{new_resource.version}"
end
