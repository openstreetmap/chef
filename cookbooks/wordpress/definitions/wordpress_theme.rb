#
# Cookbook Name:: wordpress
# Definition:: wordpress_theme
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

define :wordpress_theme, :action => [:enable] do
  name = params[:name]
  site = params[:site]
  site_directory = node[:wordpress][:sites][site][:directory]
  theme_directory = "#{site_directory}/wp-content/themes/#{name}"
  source = params[:source]

  if source
    remote_directory theme_directory do
      cookbook "wordpress"
      source source
      owner node[:wordpress][:user]
      group node[:wordpress][:group]
      mode 0755
      files_owner node[:wordpress][:user]
      files_group node[:wordpress][:group]
      files_mode 0644
    end
  else
    unless repository = params[:repository]
      version = params[:version] || node[:wordpress][:plugins][name][:version]
      repository = "http://themes.svn.wordpress.org/#{name}/#{version}"
    end

    if repository =~ /\.git$/
      git theme_directory do
        action :sync
        repository repository
        revision params[:revision]
        user node[:wordpress][:user]
        group node[:wordpress][:group]
        notifies :reload, "service[apache2]"
      end
    else
      subversion theme_directory do
        action :sync
        repository repository
        user node[:wordpress][:user]
        group node[:wordpress][:group]
        ignore_failure repository.start_with?("http://themes.svn.wordpress.org/")
        notifies :reload, "service[apache2]"
      end
    end
  end
end
