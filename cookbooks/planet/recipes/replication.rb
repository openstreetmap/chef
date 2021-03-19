#
# Cookbook:: planet
# Recipe:: dump
#
# Copyright:: 2013, OpenStreetMap Foundation
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

require "yaml"

include_recipe "accounts"
include_recipe "apt"
include_recipe "osmosis"

db_passwords = data_bag_item("db", "passwords")

## Install required packages

package %w[
  postgresql-client
  ruby
  ruby-dev
  ruby-libxml
  make
  gcc
  libc6-dev
  libpq-dev
  osmdbt
]

gem_package "pg"

## Build preload library to flush files

remote_directory "/opt/flush" do
  source "flush"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

execute "/opt/flush/Makefile" do
  action :nothing
  command "make"
  cwd "/opt/flush"
  user "root"
  group "root"
  subscribes :run, "remote_directory[/opt/flush]"
end

## Install scripts

remote_directory "/usr/local/bin" do
  source "replication-bin"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

template "/usr/local/bin/replicate-minute" do
  source "replicate-minute.erb"
  owner "root"
  group "root"
  mode "755"
end

template "/usr/local/bin/users-agreed" do
  source "users-agreed.erb"
  owner "root"
  group "root"
  mode "755"
end

template "/usr/local/bin/users-deleted" do
  source "users-deleted.erb"
  owner "root"
  group "root"
  mode "755"
end

## Published deleted users directory

remote_directory "/store/planet/users_deleted" do
  source "users_deleted"
  owner "planet"
  group "planet"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "644"
end

## Published replication directory

remote_directory "/store/planet/replication" do
  source "replication-cgi"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

## Configuration directory

directory "/etc/replication" do
  owner "root"
  group "root"
  mode "755"
end

## Transient state directory

systemd_tmpfile "/run/replication" do
  type "d"
  owner "planet"
  group "planet"
  mode "755"
end

## Persistent state directory

directory "/var/lib/replication" do
  owner "planet"
  group "planet"
  mode "755"
end

## Temporary directory

directory "/store/replication" do
  owner "planet"
  group "planet"
  mode "755"
end

## Users replication

template "/etc/replication/users-agreed.conf" do
  source "users-agreed.conf.erb"
  user "planet"
  group "planet"
  mode "600"
  variables :password => db_passwords["planetdiff"]
end

## Changeset replication

directory "/store/planet/replication/changesets" do
  owner "planet"
  group "planet"
  mode "755"
end

template "/etc/replication/changesets.conf" do
  source "changesets.conf.erb"
  user "root"
  group "planet"
  mode "640"
  variables :password => db_passwords["planetdiff"]
end

## Minutely replication

directory "/store/planet/replication/minute" do
  owner "planet"
  group "planet"
  mode "755"
end

directory "/var/lib/replication/minute" do
  owner "planet"
  group "planet"
  mode "755"
end

directory "/store/replication/minute" do
  owner "planet"
  group "planet"
  mode "755"
end

osmdbt_config = {
  "database" => {
    "host" => node[:web][:database_host],
    "dbname" => "openstreetmap",
    "user" => "planetdiff",
    "password" => db_passwords["planetdiff"],
    "replication_slot" => "osmdbt"
  },
  "log_dir" => "/var/lib/replication/minute",
  "changes_dir" => "/store/planet/replication/minute",
  "tmp_dir" => "/store/replication/minute",
  "run_dir" => "/run/replication"
}

file "/etc/replication/osmdbt-config.yaml" do
  user "root"
  group "planet"
  mode "640"
  content YAML.dump(osmdbt_config)
end

systemd_service "replication-minutely" do
  description "Minutely replication"
  user "planet"
  working_directory "/etc/replication"
  exec_start "/usr/local/bin/replicate-minute"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  restrict_address_families %w[AF_INET AF_INET6]
  no_new_privileges true
end

systemd_timer "replication-minutely" do
  description "Minutely replication"
  on_boot_sec 60
  on_unit_active_sec 60
  accuracy_sec 5
end

## Hourly replication

directory "/store/planet/replication/hour" do
  owner "planet"
  group "planet"
  mode "755"
end

directory "/var/lib/replication/hour" do
  owner "planet"
  group "planet"
  mode "755"
end

link "/var/lib/replication/hour/data" do
  to "/store/planet/replication/hour"
end

template "/var/lib/replication/hour/configuration.txt" do
  source "replication.config.erb"
  owner "planet"
  group "planet"
  mode "644"
  variables :base => "minute", :interval => 3600
end

systemd_service "replication-hourly" do
  description "Hourly replication"
  user "planet"
  exec_start "/usr/local/bin/osmosis -q --merge-replication-files workingDirectory=/var/lib/replication/hour"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  restrict_address_families %w[AF_INET AF_INET6]
  no_new_privileges true
end

systemd_timer "replication-hourly" do
  description "Daily replication"
  on_calendar "*-*-* *:02/15:00"
end

## Daily replication

directory "/store/planet/replication/day" do
  owner "planet"
  group "planet"
  mode "755"
end

directory "/var/lib/replication/day" do
  owner "planet"
  group "planet"
  mode "755"
end

link "/var/lib/replication/day/data" do
  to "/store/planet/replication/day"
end

template "/var/lib/replication/day/configuration.txt" do
  source "replication.config.erb"
  owner "planet"
  group "planet"
  mode "644"
  variables :base => "hour", :interval => 86400
end

systemd_service "replication-daily" do
  description "Daily replication"
  user "planet"
  exec_start "/usr/local/bin/osmosis -q --merge-replication-files workingDirectory=/var/lib/replication/day"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  restrict_address_families %w[AF_INET AF_INET6]
  no_new_privileges true
end

systemd_timer "replication-daily" do
  description "Daily replication"
  on_calendar "*-*-* *:02/15:00"
end

## Enable/disable feeds

if node[:planet][:replication] == "enabled"
  cron_d "users-agreed" do
    minute "0"
    hour "7"
    user "planet"
    command "/usr/local/bin/users-agreed"
    mailto "zerebubuth@gmail.com"
  end

  cron_d "users-deleted" do
    minute "0"
    hour "17"
    user "planet"
    command "/usr/local/bin/users-deleted"
    mailto "zerebubuth@gmail.com"
  end

  cron_d "replication-changesets" do
    user "planet"
    command "/usr/local/bin/replicate-changesets /etc/replication/changesets.conf"
    mailto "zerebubuth@gmail.com"
  end

  service "replication-minutely.timer" do
    action [:enable, :start]
  end

  service "replication-hourly.timer" do
    action [:enable, :start]
  end

  service "replication-daily.timer" do
    action [:enable, :start]
  end
else
  cron_d "users-agreed" do
    action :delete
  end

  cron_d "users-deleted" do
    action :delete
  end

  cron_d "replication-changesets" do
    action :delete
  end

  service "replication-minutely.timer" do
    action [:stop, :disable]
  end

  service "replication-hourly.timer" do
    action [:stop, :disable]
  end

  service "replication-daily.timer" do
    action [:stop, :disable]
  end
end
