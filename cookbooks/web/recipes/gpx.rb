#
# Cookbook Name:: web
# Recipe:: gpx
#
# Copyright 2011, OpenStreetMap Foundation
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

include_recipe "web::base"

db_passwords = data_bag_item("db", "passwords")

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

gpx_directory = "#{node[:web][:base_directory]}/gpx-import"
pid_directory = node[:web][:pid_directory]
log_directory = node[:web][:log_directory]

execute "gpx-import-build" do
  action :nothing
  command "make DB=postgres"
  cwd "#{gpx_directory}/src"
  user "rails"
  group "rails"
end

git gpx_directory do
  action :sync
  repository "git://git.openstreetmap.org/gpx-import.git"
  revision "live"
  user "rails"
  group "rails"
  notifies :run, "execute[gpx-import-build]", :immediate
end

template "/etc/init.d/gpx-import" do
  source "init.gpx.erb"
  owner "root"
  group "root"
  mode 0755
  variables :gpx_directory => gpx_directory,
            :pid_directory => pid_directory,
            :log_directory => log_directory,
            :database_host => node[:web][:database_host],
            :database_name => "openstreetmap",
            :database_username => "gpximport",
            :database_password => db_passwords["gpximport"]
end

if %w(database_offline database_readonly gpx_offline).include?(node[:web][:status])
  service "gpx-import" do
    action :stop
  end
else
  service "gpx-import" do
    action [:enable, :start]
    supports :restart => true, :reload => true
    subscribes :restart, "execute[gpx-import-build]"
    subscribes :restart, "template[/etc/init.d/gpx-import]"
  end
end
