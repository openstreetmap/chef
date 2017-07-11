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

systemd_service "gpx-import" do
  description "GPX Import Daemon"
  after "network.target"
  type "forking"
  environment_file "GPX_SLEEP_TIME" => "40",
                   "GPX_PATH_TRACES" => "/store/rails/gpx/traces",
                   "GPX_PATH_IMAGES" => "/store/rails/gpx/images",
                   "GPX_PATH_TEMPLATES" => "#{gpx_directory}/templates/",
                   "GPX_PGSQL_HOST" => node[:web][:database_host],
                   "GPX_PGSQL_USER" => "gpximport",
                   "GPX_PGSQL_PASS" => db_passwords["gpximport"],
                   "GPX_PGSQL_DB" => "openstreetmap",
                   "GPX_LOG_FILE" => "#{log_directory}/gpx-import.log",
                   "GPX_PID_FILE" => "#{pid_directory}/gpx-import.pid",
                   "GPX_MAIL_SENDER" => "bounces@openstreetmap.org"
  user "rails"
  exec_start "#{gpx_directory}/src/gpx-import"
  exec_reload "/bin/kill -HUP $MAINPID"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  restart "on-failure"
  pid_file "#{pid_directory}/gpx-import.pid"
end

if %w[database_offline database_readonly gpx_offline].include?(node[:web][:status])
  service "gpx-import" do
    action :stop
  end
else
  service "gpx-import" do
    action [:enable, :start]
    supports :restart => true, :reload => true
    subscribes :restart, "execute[gpx-import-build]"
    subscribes :restart, "systemd_service[gpx-import]"
  end
end
