#
# Cookbook:: blogs
# Recipe:: default
#
# Copyright:: 2016, OpenStreetMap Foundation
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

include_recipe "accounts"
include_recipe "apache"
include_recipe "git"
include_recipe "ruby"

package %w[
  make
  gcc
  g++
  libsqlite3-dev
  sqlite3
]

group "blogs" do
  gid 525
end

user "blogs" do
  uid 525
  gid 525
  comment "blogs.openstreetmap.org"
  home "/srv/blogs.openstreetmap.org"
  shell "/usr/sbin/nologin"
  manage_home false
end

directory "/srv/blogs.openstreetmap.org" do
  owner "blogs"
  group "blogs"
  mode "755"
end

git "/srv/blogs.openstreetmap.org" do
  action :sync
  repository "https://github.com/gravitystorm/blogs.osm.org.git"
  depth 1
  user "blogs"
  group "blogs"
end

bundle_config "/srv/blogs.openstreetmap.org" do
  action :nothing
  user "blogs"
  group "blogs"
  settings "deployment" => "true",
           "without" => "development:test",
           "build.sqlite3" => "--enable-system-libraries"
  subscribes :create, "git[/srv/blogs.openstreetmap.org]", :immediately
end

bundle_install "/srv/blogs.openstreetmap.org" do
  action :nothing
  user "blogs"
  group "blogs"
  subscribes :run, "git[/srv/blogs.openstreetmap.org]", :immediately
end

bundle_exec "/srv/blogs.openstreetmap.org" do
  action :nothing
  command "pluto build -t osm -o build"
  user "blogs"
  group "blogs"
  subscribes :run, "git[/srv/blogs.openstreetmap.org]", :immediately
  retries 2 # May fail on first run due to faulty blogs
end

ssl_certificate "blogs.openstreetmap.org" do
  domains ["blogs.openstreetmap.org", "blogs.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_site "blogs.openstreetmap.org" do
  template "apache.erb"
  directory "/srv/blogs.openstreetmap.org/build"
  variables :aliases => ["blogs.osm.org"]
end

template "/usr/local/bin/blogs-update" do
  source "blogs-update.erb"
  owner "root"
  group "root"
  mode "0755"
end

systemd_service "blogs-update" do
  description "Update blog aggregator"
  exec_start "/usr/local/bin/blogs-update"
  user "blogs"
  sandbox :enable_network => true
  read_write_paths "/srv/blogs.openstreetmap.org"
end

systemd_timer "blogs-update" do
  description "Update blog aggregator"
  on_boot_sec "15m"
  on_unit_inactive_sec "30m"
end

service "blogs-update.timer" do
  action [:enable, :start]
end

template "/etc/cron.daily/blogs-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "0755"
end
