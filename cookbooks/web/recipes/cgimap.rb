#
# Cookbook Name:: web
# Recipe:: cgimap
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

include_recipe "tools"
include_recipe "web::base"

db_passwords = data_bag_item("db", "passwords")

package "gcc"
package "make"
package "autoconf"
package "automake"
package "libtool"
package "libfcgi-dev"
package "libxml2-dev"
package "libmemcached-dev"
package "libboost-regex-dev"
package "libboost-system-dev"
package "libboost-program-options-dev"
package "libboost-date-time-dev"
package "libboost-filesystem-dev"
package "libpqxx3-dev"
package "zlib1g-dev"

cgimap_directory = "#{node[:web][:base_directory]}/cgimap"
pid_directory = node[:web][:pid_directory]
log_directory = node[:web][:log_directory]

execute "cgimap-build" do
  action :nothing
  command "make"
  cwd cgimap_directory
  user "rails"
  group "rails"
end

execute "cgimap-configure" do
  action :nothing
  command "./configure --with-fcgi=/usr --with-boost-libdir=/usr/lib/x86_64-linux-gnu"
  cwd cgimap_directory
  user "rails"
  group "rails"
  notifies :run, "execute[cgimap-build]", :immediate
end

execute "cgimap-autogen" do
  action :nothing
  command "./autogen.sh"
  cwd cgimap_directory
  user "rails"
  group "rails"
  notifies :run, "execute[cgimap-configure]", :immediate
end

git cgimap_directory do
  action :sync
  repository "git://git.openstreetmap.org/cgimap.git"
  revision "live"
  user "rails"
  group "rails"
  notifies :run, "execute[cgimap-autogen]", :immediate
end

if node[:web][:readonly_database_host]
  database_host = node[:web][:readonly_database_host]
  database_readonly = true
else
  database_host = node[:web][:database_host]
  database_readonly = node[:web][:status] == "database_readonly"
end

cgimap_init = edit_file "#{cgimap_directory}/scripts/cgimap.init" do |line|
  line.gsub!(/^CGIMAP_HOST=.*;/, "CGIMAP_HOST=#{database_host};")
  line.gsub!(/^CGIMAP_DBNAME=.*;/, "CGIMAP_DBNAME=openstreetmap;")
  line.gsub!(/^CGIMAP_USERNAME=.*;/, "CGIMAP_USERNAME=rails;")
  line.gsub!(/^CGIMAP_PASSWORD=.*;/, "CGIMAP_PASSWORD=#{db_passwords['rails']};")
  line.gsub!(/^CGIMAP_PIDFILE=.*;/, "CGIMAP_PIDFILE=#{pid_directory}/cgimap.pid;")
  line.gsub!(/^CGIMAP_LOGFILE=.*;/, "CGIMAP_LOGFILE=#{log_directory}/cgimap.log;")
  line.gsub!(/^CGIMAP_MEMCACHE=.*;/, "CGIMAP_MEMCACHE=rails1,rails2,rails3;")

  line.gsub!(%r{/home/rails/bin/map}, "#{cgimap_directory}/.libs/lt-map")

  if database_readonly
    line.gsub!(/--daemon/, "--daemon --readonly")
  end

  line
end

file "/etc/init.d/cgimap" do
  owner "root"
  group "root"
  mode 0755
  content cgimap_init
end

if %w(database_offline api_offline).include?(node[:web][:status])
  service "cgimap" do
    action :stop
  end
else
  service "cgimap" do
    action [:enable, :start]
    supports :restart => true, :reload => true
    subscribes :restart, "execute[cgimap-build]"
    subscribes :restart, "file[/etc/init.d/cgimap]"
  end
end
