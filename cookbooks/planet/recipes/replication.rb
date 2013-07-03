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

include_recipe "osmosis"

db_passwords = data_bag_item("db", "passwords")

package "ruby"
package "ruby-libxml"

gem_package "pg"

remote_directory "/usr/local/bin" do
  source "replication-bin"
  owner "root"
  group "root"
  mode 0755
  files_owner "root"
  files_group "root"
  files_mode 0755
end

remote_directory "/store/planet/replication" do
  source "replication-cgi"
  owner "root"
  group "root"
  mode 0755
  files_owner "root"
  files_group "root"
  files_mode 0755
end

directory "/store/planet/replication/changesets" do
  owner "planet"
  group "planet"
  mode 0755
end

directory "/store/planet/replication/day" do
  owner "planet"
  group "planet"
  mode 0755
end

directory "/store/planet/replication/hour" do
  owner "planet"
  group "planet"
  mode 0755
end

directory "/store/planet/replication/minute" do
  owner "planet"
  group "planet"
  mode 0755
end

directory "/etc/replication" do
  owner "root"
  group "root"
  mode 0755
end

template "/etc/replication/auth.conf" do
  source "replication.auth.erb"
  user "root"
  group "planet"
  mode 0640
  variables :password => db_passwords["planetdiff"]
end

template "/etc/replication/changesets.conf" do
  source "changesets.conf.erb"
  user "root"
  group "planet"
  mode 0640
  variables :password => db_passwords["planetdiff"]
end

directory "/var/lib/replication" do
  owner "planet"
  group "planet"
  mode 0755
end

directory "/var/lib/replication/hour" do
  owner "planet"
  group "planet"
  mode 0755
end

template "/var/lib/replication/hour/configuration.txt" do
  source "replication.config.erb"
  owner "planet"
  group "planet"
  mode 0644
  variables :base => "minute", :interval => 3600
end

link "/var/lib/replication/hour/data" do
  to "/store/planet/replication/hour"
end

directory "/var/lib/replication/day" do
  owner "planet"
  group "planet"
  mode 0755
end

template "/var/lib/replication/day/configuration.txt" do
  source "replication.config.erb"
  owner "planet"
  group "planet"
  mode 0644
  variables :base => "hour", :interval => 86400
end

link "/var/lib/replication/day/data" do
  to "/store/planet/replication/day"
end

template "/etc/cron.d/replication" do
  source "replication.cron.erb"
  owner "root"
  group "root"
  mode 0644
end
