#
# Cookbook:: vectortile
# Recipe:: default
#
# Copyright:: 2024, OpenStreetMap Foundation
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
include_recipe "git"
include_recipe "nginx"
include_recipe "postgresql"
include_recipe "prometheus"
include_recipe "python"
include_recipe "tools"

directory "/srv/vector.openstreetmap.org" do
  user "tileupdate"
  group "tileupdate"
  mode "755"
end

nginx_site "default" do
  action [:delete]
end

nginx_site "vector.openstreetmap.org" do
  template "nginx.erb"
end

ssl_certificate node[:fqdn] do
  domains [node[:fqdn], "vector.openstreetmap.org"]
  notifies :reload, "service[nginx]"
end

remote_directory "/srv/vector.openstreetmap.org/html" do
  source "html"
  owner "www-data"
  group "www-data"
  mode "755"
  files_owner "www-data"
  files_group "www-data"
  files_mode "644"
end

template "/srv/vector.openstreetmap.org/html/index.html" do
  source "index.html.erb"
  owner "www-data"
  group "www-data"
  mode "644"
end

postgresql_version = node[:vectortile][:database][:cluster].split("/").first
postgis_version = node[:vectortile][:database][:postgis]

package "postgresql-#{postgresql_version}-postgis-#{postgis_version}"

postgresql_user "tomh" do
  cluster node[:vectortile][:database][:cluster]
  superuser true
end

postgresql_user "pnorman" do
  cluster node[:vectortile][:database][:cluster]
  superuser true
end

postgresql_user "tilekiln" do
  cluster node[:vectortile][:database][:cluster]
end

postgresql_user "tileupdate" do
  cluster node[:vectortile][:database][:cluster]
end

postgresql_database "tiles" do
  cluster node[:vectortile][:database][:cluster]
  owner "tileupdate"
end

postgresql_schema "tilekiln" do
  cluster node[:vectortile][:database][:cluster]
  database "tiles"
  owner "tileupdate"
  permissions "tileupdate" => :all, "tilekiln" => :usage
end

postgresql_database "spirit" do
  cluster node[:vectortile][:database][:cluster]
  owner "tileupdate"
end

postgresql_extension "postgis" do
  cluster node[:vectortile][:database][:cluster]
  database "spirit"
end

# Get a recent osm2pgsql version with backports.
apt_preference "osm2pgsql" do
  pin "release o=Debian Backports"
  pin_priority "600"
end

apt_package "osm2pgsql"

style_directory = "/srv/vector.openstreetmap.org/spirit"
git style_directory do
  repository "https://github.com/pnorman/spirit.git"
  # Check out head for now
  # revision "61db723"
  user "tileupdate"
  group "tileupdate"
end

themepark_directory = "/srv/vector.openstreetmap.org/osm2pgsql-themepark"
git themepark_directory do
  repository "https://github.com/osm2pgsql-dev/osm2pgsql-themepark.git"
  user "tileupdate"
  group "tileupdate"
end

tilekiln_directory = "/opt/tilekiln"

python_virtualenv tilekiln_directory do
  interpreter "/usr/bin/python3"
end

python_package "tilekiln" do
  python_virtualenv tilekiln_directory
  python_version "3"
  version "0.5.1"
end

template "/srv/vector.openstreetmap.org/html/index.html" do
  source "index.html.erb"
  owner "www-data"
  group "www-data"
  mode "644"
end

directory "/srv/vector.openstreetmap.org/data" do
  user "tileupdate"
  group "tileupdate"
  mode "755"
end

template "/usr/local/bin/import-planet" do
  source "import-planet.erb"
  owner "root"
  group "root"
  mode "755"
end

template "/usr/local/bin/tilekiln-storage-init" do
  source "tilekiln-storage-init.erb"
  owner "root"
  group "root"
  mode "755"
  variables :tilekiln_bin => "#{tilekiln_directory}/bin/tilekiln", :storage_database => "tiles", :config_path => "#{style_directory}/spirit.yaml"
end

directory "/srv/vector.openstreetmap.org/complete" do
  user "root"
  group "root"
  mode "755"
end

execute "tilekiln-storage-init" do
  command "/usr/local/bin/tilekiln-storage-init"
  user "tileupdate"
  not_if { ::File.exist?("/srv/vector.openstreetmap.org/complete/tilekiln-storage-init") }
  notifies :create, "file[/srv/vector.openstreetmap.org/complete/tilekiln-storage-init]", :immediately
end

file "/srv/vector.openstreetmap.org/complete/tilekiln-storage-init" do
  action :nothing
  content "lockfile for tilekiln-storage-init"
end

postgresql_table "metadata" do
  cluster node[:vectortile][:database][:cluster]
  database "tiles"
  schema "tilekiln"
  owner "tileupdate"
  permissions "tileupdate" => :all, "tilekiln" => :select
end

systemd_service "tilekiln" do
  description "Tilekiln vector tile server"
  user "tilekiln"
  after "postgresql.service"
  wants "postgresql.service"

  exec_start "#{tilekiln_directory}/bin/tilekiln serve static --storage-dbname tiles --num-threads #{node[:vectortile][:serve][:threads]}"
end

service "tilekiln" do
  action [:enable, :start]
  supports :restart => true
end
