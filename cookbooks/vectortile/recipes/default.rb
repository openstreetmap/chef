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
  domains [node[:fqdn]]
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

# Spirit dependencies
package %w[
  osm2pgsql
  gdal-bin
  python3-yaml
  python3-psycopg2
]

style_directory = "/srv/vector.openstreetmap.org/spirit"
git style_directory do
  repository "https://github.com/pnorman/spirit.git"
  user "tileupdate"
  group "tileupdate"
end

shortbread_config = "#{style_directory}/shortbread.yaml"

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
  version "0.6.1"
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

node_store_options = node[:vectortile][:database][:nodes_store] == :flat ? "--flat-nodes '/srv/vector.openstreetmap.org/data/nodes.bin'" : ""
template "/usr/local/bin/import-planet" do
  source "import-planet.erb"
  owner "root"
  group "root"
  mode "755"
  variables :node_store_options => "#{node_store_options}"
end

template "/usr/local/bin/tilekiln-storage-init" do
  source "tilekiln-storage-init.erb"
  owner "root"
  group "root"
  mode "755"
  variables :tilekiln_bin => "#{tilekiln_directory}/bin/tilekiln", :storage_database => "tiles", :config_path => "#{shortbread_config}"
end

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

postgresql_database "spirit" do
  cluster node[:vectortile][:database][:cluster]
  owner "tileupdate"
end

postgresql_extension "postgis" do
  cluster node[:vectortile][:database][:cluster]
  database "spirit"
end

postgresql_schema "tilekiln" do
  cluster node[:vectortile][:database][:cluster]
  database "tiles"
  owner "tileupdate"
  permissions "tileupdate" => :all, "tilekiln" => :usage
  notifies :run, "execute[tilekiln-storage-init]", :immediately
end

execute "tilekiln-storage-init" do
  action :nothing
  command "/usr/local/bin/tilekiln-storage-init"
  user "tileupdate"
end

%w[metadata shortbread_v1].each do |table|
  postgresql_table table do
    cluster node[:vectortile][:database][:cluster]
    database "tiles"
    schema "tilekiln"
    owner "tileupdate"
    permissions "tileupdate" => :all, "tilekiln" => :select
  end
end

(0..14).each do |zoom|
  postgresql_table "shortbread_v1_z#{zoom}" do
    cluster node[:vectortile][:database][:cluster]
    database "tiles"
    schema "tilekiln"
    owner "tileupdate"
    permissions "tileupdate" => :all, "tilekiln" => node[:vectortile][:serve][:mode] == :live ? [:select, :insert, :update] : :select
  end
end

%w[addresses aerialways aeroways boundaries boundary_labels bridges buildings
dam_lines dam_polygons ferries land pier_lines pier_polygons place_labels
planet_osm_nodes planet_osm_rels planet_osm_ways pois public_transport railways
road_routes roads sites street_polygons streets_labels_points
streets_polygons_labels water_area_labels water_areas water_lines water_lines_labels].each do |table|
  postgresql_table table do
    cluster node[:vectortile][:database][:cluster]
    database "spirit"
    schema "public"
    owner "tileupdate"
    permissions "tileupdate" => :all, "tilekiln" => :select
  end
end

tilekiln_mode = node[:vectortile][:serve][:mode] == :live ? "live --config #{shortbread_config} --source-dbname spirit" : "static"

systemd_service "tilekiln" do
  description "Tilekiln vector tile server"
  user "tilekiln"
  after "postgresql.service"
  wants "postgresql.service"
  sandbox :enable_network => true
  restrict_address_families "AF_UNIX"
  exec_start "#{tilekiln_directory}/bin/tilekiln serve #{tilekiln_mode} --storage-dbname tiles --num-threads #{node[:vectortile][:serve][:threads]} --base-url 'https://vector.openstreetmap.org'"
end

service "tilekiln" do
  action [:enable, :start]
end

execute "/srv/vector.openstreetmap.org/spirit/scripts/get-external-data.py" do
  command "/srv/vector.openstreetmap.org/spirit/scripts/get-external-data.py -R tilekiln"
  cwd "/srv/vector.openstreetmap.org/spirit"
  user "tileupdate"
  group "tileupdate"
  ignore_failure true
end

template "/usr/local/bin/vector-update" do
  source node[:vectortile][:replication][:tileupdate] == :enabled ? "vector-update-tile.erb" : "vector-update-notile.erb"
  owner "root"
  group "root"
  mode "755"
  variables :tilekiln_bin => "#{tilekiln_directory}/bin/tilekiln", :source_database => "spirit", :config_path => "#{shortbread_config}", :diff_size => "1000", :tiles_file => "/srv/vector.openstreetmap.org/data/tiles.txt", :post_processing => "/usr/local/bin/tiles-rerender"
end

template "/usr/local/bin/tiles-rerender" do
  source "tiles-rerender.erb"
  owner "root"
  group "root"
  mode "755"
  variables :tilekiln_bin => "#{tilekiln_directory}/bin/tilekiln", :source_database => "spirit", :storage_database => "tiles", :config_path => "#{shortbread_config}", :tiles_file => "/srv/vector.openstreetmap.org/data/tiles.txt", :update_threads => 4
end

systemd_service "replicate" do
  description "Get replication updates"
  user "tileupdate"
  after "postgresql.service"
  wants "postgresql.service"
  sandbox :enable_network => true
  restrict_address_families "AF_UNIX"
  read_write_paths ["/srv/vector.openstreetmap.org/data/"]
  exec_start "/usr/local/bin/vector-update"
end

systemd_timer "replicate" do
  description "Get replication updates"
  on_boot_sec 60
  on_unit_active_sec 30
  accuracy_sec 5
end

if node[:vectortile][:replication][:status] == :enabled
  service "replicate.timer" do
    action [:enable, :start]
  end
else
  service "replicate.timer" do
    action [:stop, :disable]
  end
end
