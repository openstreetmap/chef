#
# Cookbook:: tile
# Recipe:: default
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

include_recipe "accounts"
include_recipe "apache"
include_recipe "git"
include_recipe "nodejs"
include_recipe "postgresql"
include_recipe "prometheus"
include_recipe "python"
include_recipe "ruby"
include_recipe "tools"

blocks = data_bag_item("tile", "blocks")
admins = data_bag_item("apache", "admins")
web_passwords = data_bag_item("web", "passwords")

apache_module "alias"
apache_module "cgi"
apache_module "expires"
apache_module "headers"
apache_module "remoteip"
apache_module "rewrite"

apache_module "tile" do
  conf "tile.conf.erb"
end

apache_conf "renderd" do
  action :disable
end

ssl_certificate node[:fqdn] do
  domains [node[:fqdn], "tile.openstreetmap.org", "render.openstreetmap.org"]
  notifies :reload, "service[apache2]"
end

remote_file "#{Chef::Config[:file_cache_path]}/fastly-ip-list.json" do
  source "https://api.fastly.com/public-ip-list"
  compile_time true
  ignore_failure true
end

fastlyips = JSON.parse(IO.read("#{Chef::Config[:file_cache_path]}/fastly-ip-list.json"))

remote_file "#{Chef::Config[:file_cache_path]}/statuscake-locations.json" do
  source "https://app.statuscake.com/Workfloor/Locations.php?format=json"
  compile_time true
  ignore_failure true
end

statuscakelocations = JSON.parse(IO.read("#{Chef::Config[:file_cache_path]}/statuscake-locations.json"))

apache_site "default" do
  action :disable
end

apache_site "tileserver_site" do
  action :disable
end

apache_site "tile.openstreetmap.org" do
  template "apache.erb"
  variables :fastly => fastlyips["addresses"] + fastlyips["ipv6_addresses"],
            :statuscake => statuscakelocations.flat_map { |_, v| [v["ip"], v["ipv6"]] },
            :admins => admins["hosts"]
end

template "/etc/logrotate.d/apache2" do
  source "logrotate.apache.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/srv/tile.openstreetmap.org" do
  owner "tile"
  group "tile"
  mode "755"
end

tile_directories = node[:tile][:styles].collect do |_, style|
  style[:tile_directories].collect { |directory| directory[:name] }
end.flatten.sort.uniq

package %w[
  renderd
  libgoogle-perftools4
]

systemd_service "renderd" do
  dropin "chef"
  after "postgresql.service"
  wants "postgresql.service"
  environment "LD_PRELOAD" => "libtcmalloc.so.4"
  limit_nofile 4096
  memory_high "80%"
  memory_max "90%"
  sandbox true
  restrict_address_families "AF_UNIX"
  read_write_paths tile_directories
  system_call_filter ["@system-service", "mincore"]
  restart "on-failure"
end

service "renderd" do
  action [:enable, :start]
  subscribes :restart, "systemd_service[renderd]"
end

directory "/srv/tile.openstreetmap.org/tiles" do
  owner "tile"
  group "tile"
  mode "755"
end

template "/etc/renderd.conf" do
  source "renderd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :reload, "service[apache2]"
  notifies :restart, "service[renderd]"
end

remote_directory "/srv/tile.openstreetmap.org/html" do
  source "html"
  owner "tile"
  group "tile"
  mode "755"
  files_owner "tile"
  files_group "tile"
  files_mode "644"
end

template "/srv/tile.openstreetmap.org/html/index.html" do
  source "index.html.erb"
  owner "tile"
  group "tile"
  mode "644"
end

package %w[
  python3-cairo
  python3-mapnik
  python3-pyotp
  python3-pyproj
  python3-setuptools
]

directory "/srv/tile.openstreetmap.org/cgi-bin" do
  owner "tile"
  group "tile"
  mode "755"
end

template "/srv/tile.openstreetmap.org/cgi-bin/export" do
  source "export.erb"
  owner "tile"
  group "tile"
  mode "755"
  variables :blocks => blocks, :totp_key => web_passwords["totp_key"]
end

template "/srv/tile.openstreetmap.org/cgi-bin/debug" do
  source "debug.erb"
  owner "tile"
  group "tile"
  mode "755"
end

systemd_service "export-cleanup" do
  description "Cleanup stale export temporary files"
  joins_namespace_of "apache2.service"
  exec_start "find /tmp -ignore_readdir_race -name 'export??????' -mmin +60 -delete"
  user "www-data"
  sandbox true
end

systemd_timer "export-cleanup" do
  description "Cleanup stale export temporary files"
  on_boot_sec "60m"
  on_unit_inactive_sec "60m"
end

service "export-cleanup.timer" do
  action [:enable, :start]
end

directory "/srv/tile.openstreetmap.org/data" do
  owner "tile"
  group "tile"
  mode "755"
end

package %w[
  mapnik-utils
  tar
  unzip
]

node[:tile][:data].each_value do |data|
  url = data[:url]
  file = "/srv/tile.openstreetmap.org/data/#{File.basename(url)}"

  if data[:directory]
    directory = "/srv/tile.openstreetmap.org/data/#{data[:directory]}"

    directory directory do
      owner "tile"
      group "tile"
      mode "755"
    end
  else
    directory = "/srv/tile.openstreetmap.org/data"
  end

  if file =~ /\.tgz$/
    execute file do
      action :nothing
      command "tar -zxf #{file} -C #{directory}"
      user "tile"
      group "tile"
    end
  elsif file =~ /\.tar\.bz2$/
    execute file do
      action :nothing
      command "tar -jxf #{file} -C #{directory}"
      user "tile"
      group "tile"
    end
  elsif file =~ /\.zip$/
    execute file do
      action :nothing
      command "unzip -qq -o #{file} -d #{directory}"
      user "tile"
      group "tile"
    end
  end

  execute "#{file}_shapeindex" do
    action :nothing
    command "find #{directory} -type f -iname '*.shp' -print0 | xargs -0 --no-run-if-empty shapeindex --shape_files"
    user "tile"
    group "tile"
    subscribes :run, "execute[#{file}]", :immediately
  end

  remote_file file do
    if data[:refresh]
      action :create
      use_conditional_get true
      ignore_failure true
    else
      action :create_if_missing
    end

    source url
    owner "tile"
    group "tile"
    mode "644"
    backup false
    notifies :run, "execute[#{file}]", :immediately
    notifies :restart, "service[renderd]"
  end
end

nodejs_package "carto"

lowzoom_threads = node.cpu_cores - 1

systemd_service "update-lowzoom@" do
  description "Low zoom tile update service for %i layer"
  user "tile"
  exec_start_pre "+/bin/systemctl stop render-lowzoom.service"
  exec_start "/bin/bash /usr/local/bin/update-lowzoom-%i"
  runtime_directory "update-lowzoom-%i"
  sandbox true
  restrict_address_families "AF_UNIX"
  read_write_paths [
    "/srv/tile.openstreetmap.org/tiles/%i",
    "/var/log/tile"
  ]
  restart "on-failure"
end

directory "/srv/tile.openstreetmap.org/styles" do
  owner "tile"
  group "tile"
  mode "755"
end

node[:tile][:styles].each do |name, details|
  style_directory = "/srv/tile.openstreetmap.org/styles/#{name}"
  tile_directory = "/srv/tile.openstreetmap.org/tiles/#{name}"

  template "/usr/local/bin/update-lowzoom-#{name}" do
    source "update-lowzoom.erb"
    owner "root"
    group "root"
    mode "755"
    variables :style => name, :threads => lowzoom_threads
  end

  service "update-lowzoom@#{name}" do
    action :disable
    supports :restart => true
  end

  directory tile_directory do
    owner "tile"
    group "tile"
    mode "755"
  end

  details[:tile_directories].each do |directory|
    directory directory[:name] do
      owner "_renderd"
      group "_renderd"
      mode "755"
    end

    directory[:min_zoom].upto(directory[:max_zoom]) do |zoom|
      directory "#{directory[:name]}/#{zoom}" do
        owner "_renderd"
        group "_renderd"
        mode "755"
      end

      link "#{tile_directory}/#{zoom}" do
        to "#{directory[:name]}/#{zoom}"
        owner "tile"
        group "tile"
      end
    end
  end

  file "#{tile_directory}/planet-import-complete" do
    action :create_if_missing
    owner "tile"
    group "tile"
    mode "444"
  end

  git style_directory do
    action :sync
    repository details[:repository]
    revision details[:revision]
    user "tile"
    group "tile"
  end

  link "#{style_directory}/data" do
    to "/srv/tile.openstreetmap.org/data"
    owner "tile"
    group "tile"
  end

  if details[:fonts_script]
    execute details[:fonts_script] do
      action :nothing
      command details[:fonts_script]
      cwd style_directory
      user "tile"
      group "tile"
      subscribes :run, "git[#{style_directory}]"
    end
  end

  execute "#{style_directory}/project.mml" do
    action :nothing
    command "carto -a 3.0.22 project.mml > project.xml"
    cwd style_directory
    user "tile"
    group "tile"
    subscribes :run, "git[#{style_directory}]"
    notifies :restart, "service[renderd]", :immediately
    notifies :restart, "service[update-lowzoom@#{name}]"
  end
end

postgresql_version = node[:tile][:database][:cluster].split("/").first
postgis_version = node[:tile][:database][:postgis]

package "postgresql-#{postgresql_version}-postgis-#{postgis_version}"

postgresql_user "jburgess" do
  cluster node[:tile][:database][:cluster]
  superuser true
end

postgresql_user "tomh" do
  cluster node[:tile][:database][:cluster]
  superuser true
end

postgresql_user "pnorman" do
  cluster node[:tile][:database][:cluster]
  superuser true
end

postgresql_user "tile" do
  cluster node[:tile][:database][:cluster]
end

postgresql_user "www-data" do
  cluster node[:tile][:database][:cluster]
end

postgresql_user "_renderd" do
  cluster node[:tile][:database][:cluster]
end

postgresql_database "gis" do
  cluster node[:tile][:database][:cluster]
  owner "tile"
end

postgresql_extension "postgis" do
  cluster node[:tile][:database][:cluster]
  database "gis"
end

postgresql_extension "hstore" do
  cluster node[:tile][:database][:cluster]
  database "gis"
  only_if { node[:tile][:database][:hstore] }
end

%w[geography_columns planet_osm_nodes planet_osm_rels planet_osm_ways raster_columns raster_overviews].each do |table|
  postgresql_table table do
    cluster node[:tile][:database][:cluster]
    database "gis"
    owner "tile"
    permissions "tile" => :all
  end
end

%w[geometry_columns planet_osm_line planet_osm_point planet_osm_polygon planet_osm_roads spatial_ref_sys].each do |table|
  postgresql_table table do
    cluster node[:tile][:database][:cluster]
    database "gis"
    owner "tile"
    permissions "tile" => :all, "www-data" => :select, "_renderd" => :select
  end
end

package %w[
  gdal-bin
  python3-yaml
  python3-psycopg2
]

if node[:tile][:database][:external_data_script]
  execute node[:tile][:database][:external_data_script] do
    command "#{node[:tile][:database][:external_data_script]} -R _renderd"
    cwd "/srv/tile.openstreetmap.org"
    user "tile"
    group "tile"
    ignore_failure true
  end

  Array(node[:tile][:database][:external_data_tables]).each do |table|
    postgresql_table table do
      cluster node[:tile][:database][:cluster]
      database "gis"
      owner "tile"
      permissions "tile" => :all, "www-data" => :select, "_renderd" => :select
    end
  end
end

directory File.dirname(node[:tile][:database][:node_file]) do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

file node[:tile][:database][:node_file] do
  owner "tile"
  group "_renderd"
  mode "660"
end

directory "/var/log/tile" do
  owner "tile"
  group "tile"
  mode "755"
end

package %w[
  osm2pgsql
  osmium-tool
  pyosmium
]

directory node[:tile][:replication][:directory] do
  owner "tile"
  group "tile"
  mode "755"
end

link "/var/lib/replicate" do
  to node[:tile][:replication][:directory]
  owner "tile"
  group "tile"
  not_if { node[:tile][:replication][:directory] == "/var/lib/replicate" }
end

template "/usr/local/bin/expire-tiles" do
  source "expire-tiles.erb"
  owner "root"
  group "root"
  mode "755"
end

directory "/var/lib/replicate/expire-queue" do
  owner "tile"
  group "_renderd"
  mode "775"
end

template "/usr/local/bin/replicate" do
  source "replicate.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "expire-tiles" do
  description "Tile dirtying service"
  type "simple"
  user "_renderd"
  exec_start "/usr/local/bin/expire-tiles"
  nice 10
  sandbox true
  restrict_address_families "AF_UNIX"
  read_write_paths tile_directories + [
                     "/var/lib/replicate/expire-queue"
                   ]
end

systemd_path "expire-tiles" do
  description "Tile dirtying trigger"
  directory_not_empty "/var/lib/replicate/expire-queue"
end

service "expire-tiles.path" do
  action [:enable, :start]
  subscribes :restart, "systemd_path[expire-tiles]"
end

template "/usr/local/bin/replicate-post" do
  source "replicate-post.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "replicate" do
  description "Rendering database replication service"
  after "postgresql.service"
  wants "postgresql.service"
  user "tile"
  exec_start "/usr/local/bin/replicate"
  sandbox :enable_network => true
  restrict_address_families "AF_UNIX"
  read_write_paths [
    "/store/database/nodes",
    "/var/lib/replicate"
  ]
  restart "on-failure"
end

service "replicate" do
  action [:enable, :start]
  subscribes :restart, "template[/usr/local/bin/replicate]"
  subscribes :restart, "systemd_service[replicate]"
end

template "/usr/local/bin/render-lowzoom" do
  source "render-lowzoom.erb"
  owner "root"
  group "root"
  mode "755"
  variables :threads => lowzoom_threads
end

systemd_service "render-lowzoom" do
  description "Render low zoom tiles"
  condition_path_exists_glob "!/run/update-lowzoom-*"
  user "tile"
  exec_start "/usr/local/bin/render-lowzoom"
  sandbox true
  restrict_address_families "AF_UNIX"
  read_write_paths "/var/log/tile"
end

systemd_timer "render-lowzoom" do
  description "Render low zoom tiles"
  on_calendar "23:00 #{node[:timezone]}"
end

service "render-lowzoom.timer" do
  action [:enable, :start]
end

package "liblockfile-simple-perl"
package "libfilesys-df-perl"

template "/usr/local/bin/cleanup-tiles" do
  source "cleanup-tiles.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "cleanup-tiles@" do
  description "Cleanup old tiles for /%I"
  exec_start "/usr/local/bin/cleanup-tiles /%I"
  user "_renderd"
  io_scheduling_class "idle"
  sandbox true
  read_write_paths "/%I"
end

systemd_timer "cleanup-tiles@" do
  description "Cleanup old tiles for /%I"
  on_boot_sec "30m"
  on_unit_inactive_sec "60m"
  randomized_delay_sec "10m"
end

tile_directories.each do |directory|
  label = directory[1..].gsub("/", "-")

  service "cleanup-tiles@#{label}.timer" do
    action [:enable, :start]
  end
end

package "ruby-webrick"

prometheus_exporter "modtile" do
  port 9494
end

prometheus_exporter "renderd" do
  port 9393
end
