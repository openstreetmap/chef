#
# Cookbook Name:: planet
# Recipe:: dump
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

include_recipe "git"

db_passwords = data_bag_item("db", "passwords")

package "gcc"
package "make"
package "libpqxx3-dev"

directory "/opt/planetdump" do
  owner "root"
  group "root"
  mode 0755
end

git "/opt/planetdump" do
  action :sync
  repository "git://git.openstreetmap.org/planetdump.git"
  revision "live"
  user "root"
  group "root"
end

execute "/opt/planetdump/Makefile" do
  action :nothing
  command "make planet06_pg"
  cwd "/opt/planetdump"
  user "root"
  group "root"
  subscribes :run, "git[/opt/planetdump]"
end

template "/usr/local/bin/planetdump" do
  source "planetdump.erb"
  owner "root"
  group "root"
  mode 0755
  variables :password => db_passwords["planetdump"]
end

template "/etc/cron.d/planetdump" do
  source "planetdump.cron.erb"
  owner "root"
  group "root"
  mode 0644
end
