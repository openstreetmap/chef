#
# Cookbook Name:: web
# Definition:: gpx_import
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

require "yaml"

define :gpx_import, :action => [:create, :enable] do
  gpx_service_name = params[:name] || "gpx-import"
  gpx_revision = params[:revision] || "live"
  gpx_repository = params[:repository] || "git://git.openstreetmap.org/gpx-import.git"
  gpx_directory = params[:directory]
  gpx_user = params[:user]
  gpx_group = params[:group]
  gpx_pid_directory = params[:pid_directory] || "#{gpx_directory}/pid"
  gpx_log_directory = params[:log_directory] || "#{gpx_directory}/log"
  gpx_database_host = params[:database_host]
  gpx_database_port = params[:database_port]
  gpx_database_name = params[:database_name]
  gpx_database_user = params[:database_username]
  gpx_database_pass = params[:database_password]
  gpx_store_directory = params[:store_directory] || gpx_directory
  gpx_memcache_servers = params[:memcache_servers] || []
  gpx_status = params[:status] || "online"

  package "gcc"
  package "make"
  package "pkg-config"
  package "libarchive-dev"
  package "libbz2-dev"
  package "libexpat1-dev"
  package "libgd2-noxpm-dev"
  package "libmemcached-dev"
  package "libpq-dev"
  package "zlib1g-dev"

  execute "gpx-import-build" do
    action :nothing
    command "make DB=postgres"
    cwd "#{gpx_directory}/src"
    user gpx_user
    group gpx_group
  end

  git gpx_directory do
    action :sync
    repository gpx_repository
    revision gpx_revision
    user gpx_user
    group gpx_group
    notifies :run, "execute[gpx-import-build]", :immediate
  end

  template "/etc/init.d/#{gpx_service_name}" do
    source "init.gpx.erb"
    owner "root"
    group "root"
    mode 0755
    variables :gpx_directory => gpx_directory,
              :pid_directory => gpx_pid_directory,
              :log_directory => gpx_log_directory,
              :store_directory => gpx_store_directory,
              :memcache_servers => gpx_memcache_servers,
              :database_host => gpx_database_host,
              :database_port => gpx_database_port,
              :database_name => gpx_database_name,
              :database_username => gpx_database_user,
              :database_password => gpx_database_pass
  end

  if %w(database_offline database_readonly gpx_offline).include?(gpx_status)
    service gpx_service_name do
      action :stop
    end
  else
    service gpx_service_name do
      action [:enable, :start]
      supports :restart => true, :reload => true
      subscribes :restart, "execute[gpx-import-build]"
      subscribes :restart, "template[/etc/init.d/#{gpx_service_name}]"
    end
  end
end
