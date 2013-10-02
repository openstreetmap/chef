#
# Cookbook Name:: wordpress
# Definition:: wordpress_plugin
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

define :wordpress_plugin, :action => [ :enable ] do
  name = params[:name]
  site = params[:site]
  site_directory = node[:wordpress][:sites][site][:directory]
  plugin_directory = "#{site_directory}/wp-content/plugins/#{name}"
  source = params[:source]

  if source
    remote_directory plugin_directory do
      cookbook "wordpress"
      source source
      owner node[:wordpress][:user]
      group node[:wordpress][:group]
      mode 0755
      files_owner node[:wordpress][:user]
      files_group node[:wordpress][:group]
      files_mode 0755
    end
  else
    unless repository = params[:repository]
      version = params[:version] || Chef::Wordpress.current_plugin_version(name)

      if version =~ /trunk/
        repository = "http://plugins.svn.wordpress.org/#{name}/trunk"
      else
        repository = "http://plugins.svn.wordpress.org/#{name}/tags/#{version}"
      end
    end

    if repository =~ /\.git$/
      git plugin_directory do
        action :sync
        repository repository
        revision params[:revision]
        user node[:wordpress][:user]
        group node[:wordpress][:group]
        notifies :reload, "service[apache2]"
      end
    else
      subversion plugin_directory do
        action :sync
        repository repository
        user node[:wordpress][:user]
        group node[:wordpress][:group]
        ignore_failure repository.start_with?("http://plugins.svn.wordpress.org/")
        notifies :reload, "service[apache2]"
      end
    end
  end
end
