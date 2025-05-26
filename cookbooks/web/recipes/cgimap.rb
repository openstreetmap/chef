#
# Cookbook:: web
# Recipe:: cgimap
#
# Copyright:: 2011, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apt"
include_recipe "tools"
include_recipe "web::base"

db_passwords = data_bag_item("db", "passwords")

package "openstreetmap-cgimap-bin" do
  action :purge
end

package "openstreetmap-cgimap" do
  action :install
end

database_host = node[:web][:readonly_database_host] || node[:web][:database_host]

memcached_servers = node[:web][:memcached_servers] || []

cgimap_options = {
  "CGIMAP_SOCKET" => "/run/cgimap/socket",
  "CGIMAP_HOST" => database_host,
  "CGIMAP_DBNAME" => "openstreetmap",
  "CGIMAP_USERNAME" => "cgimap",
  "CGIMAP_PASSWORD" => db_passwords["cgimap"],
  "CGIMAP_PIDFILE" => "#{node[:web][:pid_directory]}/cgimap.pid",
  "CGIMAP_LOGFILE" => "#{node[:web][:log_directory]}/cgimap.log",
  "CGIMAP_MEMCACHE" => memcached_servers.join(","),
  "CGIMAP_RATELIMIT" => "204800",
  "CGIMAP_MAXDEBT" => "250",
  "CGIMAP_MODERATOR_RATELIMIT" => "1048576",
  "CGIMAP_MODERATOR_MAXDEBT" => "1280",
  "CGIMAP_MAP_AREA" => node[:web][:max_request_area],
  "CGIMAP_MAP_NODES" => node[:web][:max_number_of_nodes],
  "CGIMAP_MAX_WAY_NODES" => node[:web][:max_number_of_way_nodes],
  "CGIMAP_MAX_RELATION_MEMBERS" => node[:web][:max_number_of_relation_members],
  "CGIMAP_RATELIMIT_UPLOAD" => "true",
  "CGIMAP_BBOX_SIZE_LIMIT_UPLOAD" => "true",
  "PGAPPNAME" => "cgimap"
}

if %w[database_readonly api_readonly].include?(node[:web][:status])
  cgimap_options["CGIMAP_DISABLE_API_WRITE"] = "true"
else
  cgimap_options["CGIMAP_UPDATE_HOST"] = node[:web][:database_host]
end

systemd_service "cgimap" do
  description "OpenStreetMap API Server"
  type "forking"
  environment_file cgimap_options
  user "rails"
  group "www-data"
  umask "0002"
  exec_start "/usr/bin/openstreetmap-cgimap --daemon --instances 30"
  exec_reload "/bin/kill -HUP $MAINPID"
  runtime_directory "cgimap"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  no_new_privileges true
  restart "on-failure"
  pid_file "#{node[:web][:pid_directory]}/cgimap.pid"
end

if %w[database_offline api_offline].include?(node[:web][:status])
  service "cgimap" do
    action :stop
  end
else
  service "cgimap" do
    action [:enable, :start]
    supports :restart => true, :reload => true
    subscribes :restart, "package[openstreetmap-cgimap-bin]"
    subscribes :restart, "systemd_service[cgimap]"
  end
end
