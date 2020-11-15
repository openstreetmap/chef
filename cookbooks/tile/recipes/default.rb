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
include_recipe "munin"
include_recipe "nodejs"
include_recipe "postgresql"
include_recipe "prometheus"
include_recipe "python"
include_recipe "tools"

blocks = data_bag_item("tile", "blocks")
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

ssl_certificate node[:fqdn] do
  domains [node[:fqdn], "tile.openstreetmap.org", "render.openstreetmap.org"]
  notifies :reload, "service[apache2]"
end

remote_file "#{Chef::Config[:file_cache_path]}/fastly-ip-list.json" do
  source "https://api.fastly.com/public-ip-list"
  compile_time true
end

tilecaches = search(:node, "roles:tilecache").sort_by { |n| n[:hostname] }
fastlyips = JSON.parse(IO.read("#{Chef::Config[:file_cache_path]}/fastly-ip-list.json"))

apache_site "default" do
  action [:disable]
end

apache_site "tile.openstreetmap.org" do
  template "apache.erb"
  variables :caches => tilecaches, :fastly => fastlyips["addresses"]
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

package "renderd"

systemd_service "renderd" do
  description "Mapnik rendering daemon"
  after "postgresql.service"
  wants "postgresql.service"
  user "www-data"
  exec_start "/usr/bin/renderd -f"
  runtime_directory "renderd"
  standard_error "null"
  private_tmp true
  private_devices true
  private_network true
  protect_system "full"
  protect_home true
  no_new_privileges true
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
  python3-setuptools
]

python_package "pyotp" do
  python_version "3"
end

package %w[
  fonts-noto-cjk
  fonts-noto-hinted
  fonts-noto-unhinted
  fonts-hanazono
  ttf-unifont
]

["NotoSansArabicUI-Regular.ttf", "NotoSansArabicUI-Bold.ttf"].each do |font|
  remote_file "/usr/share/fonts/truetype/noto/#{font}" do
    action :create_if_missing
    source "https://github.com/googlei18n/noto-fonts/raw/master/hinted/#{font}"
    owner "root"
    group "root"
    mode "644"
  end
end

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

template "/etc/cron.hourly/export" do
  source "export.cron.erb"
  owner "root"
  group "root"
  mode "755"
end

directory "/srv/tile.openstreetmap.org/data" do
  owner "tile"
  group "tile"
  mode "755"
end

package "mapnik-utils"

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
    package "tar"

    execute file do
      action :nothing
      command "tar -zxf #{file} -C #{directory}"
      user "tile"
      group "tile"
    end
  elsif file =~ /\.tar\.bz2$/
    package "tar"

    execute file do
      action :nothing
      command "tar -jxf #{file} -C #{directory}"
      user "tile"
      group "tile"
    end
  elsif file =~ /\.zip$/
    package "unzip"

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

systemd_service "update-lowzoom@" do
  description "Low zoom tile update service for %i layer"
  user "tile"
  exec_start "/bin/bash /usr/local/bin/update-lowzoom-%i"
  private_tmp true
  private_devices true
  private_network true
  protect_system "full"
  protect_home true
  no_new_privileges true
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
    variables :style => name
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
      owner "www-data"
      group "www-data"
      mode "755"
    end

    directory[:min_zoom].upto(directory[:max_zoom]) do |zoom|
      directory "#{directory[:name]}/#{zoom}" do
        owner "www-data"
        group "www-data"
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

  execute "#{style_directory}/project.mml" do
    action :nothing
    command "carto -a 3.0.0 project.mml > project.xml"
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

postgresql_user "tile" do
  cluster node[:tile][:database][:cluster]
end

postgresql_user "www-data" do
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

%w[geography_columns planet_osm_nodes planet_osm_rels planet_osm_ways raster_columns raster_overviews spatial_ref_sys].each do |table|
  postgresql_table table do
    cluster node[:tile][:database][:cluster]
    database "gis"
    owner "tile"
    permissions "tile" => :all
  end
end

%w[geometry_columns planet_osm_line planet_osm_point planet_osm_polygon planet_osm_roads].each do |table|
  postgresql_table table do
    cluster node[:tile][:database][:cluster]
    database "gis"
    owner "tile"
    permissions "tile" => :all, "www-data" => :select
  end
end

postgresql_munin "gis" do
  cluster node[:tile][:database][:cluster]
  database "gis"
end

directory File.dirname(node[:tile][:database][:node_file]) do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

file node[:tile][:database][:node_file] do
  owner "tile"
  group "www-data"
  mode "660"
end

directory "/var/log/tile" do
  owner "tile"
  group "tile"
  mode "755"
end

package %w[
  osm2pgsql
  ruby
  osmium-tool
  pyosmium
  python3-pyproj
]

remote_directory "/usr/local/bin" do
  source "bin"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "755"
end

template "/usr/local/bin/expire-tiles" do
  source "expire-tiles.erb"
  owner "root"
  group "root"
  mode "755"
end

directory "/var/lib/replicate" do
  owner "tile"
  group "tile"
  mode "755"
end

directory "/var/lib/replicate/expire-queue" do
  owner "tile"
  group "www-data"
  mode "775"
end

template "/usr/local/bin/replicate" do
  source "replicate.erb"
  owner "root"
  group "root"
  mode "755"
  variables :postgresql_version => postgresql_version.to_f
end

systemd_service "expire-tiles" do
  description "Tile dirtying service"
  type "simple"
  user "www-data"
  exec_start "/usr/local/bin/expire-tiles"
  standard_output "null"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  no_new_privileges true
end

systemd_path "expire-tiles" do
  description "Tile dirtying trigger"
  directory_not_empty "/var/lib/replicate/expire-queue"
end

service "expire-tiles.path" do
  action [:enable, :start]
  subscribes :restart, "systemd_path[expire-tiles]"
end

systemd_service "replicate" do
  description "Rendering database replication service"
  after "postgresql.service"
  wants "postgresql.service"
  user "tile"
  exec_start "/usr/local/bin/replicate"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  no_new_privileges true
  restart "on-failure"
end

service "replicate" do
  action [:enable, :start]
  subscribes :restart, "template[/usr/local/bin/replicate]"
  subscribes :restart, "systemd_service[replicate]"
end

template "/etc/logrotate.d/replicate" do
  source "replicate.logrotate.erb"
  owner "root"
  group "root"
  mode "644"
end

template "/usr/local/bin/render-lowzoom" do
  source "render-lowzoom.erb"
  owner "root"
  group "root"
  mode "755"
end

systemd_service "render-lowzoom" do
  description "Render low zoom tiles"
  user "tile"
  exec_start "/usr/local/bin/render-lowzoom"
  private_tmp true
  private_devices true
  private_network true
  protect_system "full"
  protect_home true
  no_new_privileges true
end

systemd_timer "render-lowzoom" do
  description "Render low zoom tiles"
  on_calendar "Sun *-*~07/1 01:00:00"
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

tile_directories = node[:tile][:styles].collect do |_, style|
  style[:tile_directories].collect { |directory| directory[:name] }
end.flatten.sort.uniq

tile_directories.each do |directory|
  label = directory.gsub("/", "-")

  cron_d "cleanup-tiles#{label}" do
    minute "0"
    user "www-data"
    command "ionice -c 3 /usr/local/bin/cleanup-tiles #{directory}"
    mailto "admins@openstreetmap.org"
  end
end

munin_plugin "mod_tile_fresh"
munin_plugin "mod_tile_latency"
munin_plugin "mod_tile_response"
munin_plugin "mod_tile_zoom"

munin_plugin "renderd_processed"
munin_plugin "renderd_queue"
munin_plugin "renderd_queue_time"
munin_plugin "renderd_zoom"
munin_plugin "renderd_zoom_time"

munin_plugin "replication_delay"

prometheus_collector "modtile" do
  interval "1m"
end

prometheus_collector "renderd" do
  interval "1m"
end
