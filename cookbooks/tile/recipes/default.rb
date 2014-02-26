#
# Cookbook Name:: tile
# Recipe:: default
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

include_recipe "apache"
include_recipe "git"
include_recipe "nodejs"
include_recipe "postgresql"
include_recipe "tools"

blocks = data_bag_item("tile", "blocks")

apache_module "alias"
apache_module "expires"
apache_module "headers"
apache_module "remoteip"
apache_module "rewrite"

apache_module "tile" do
  conf "tile.conf.erb"
end

tilecaches = search(:node, "roles:tilecache").sort_by { |n| n[:hostname] }

apache_site "default" do
  action [ :disable ]
end

apache_site "tile.openstreetmap.org" do
  template "apache.erb"
  variables :caches => tilecaches
end

template "/etc/logrotate.d/apache2" do
  source "logrotate.apache.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/srv/tile.openstreetmap.org" do
  owner "tile"
  group "tile"
  mode 0755
end

package "renderd"

service "renderd" do
  action [ :enable, :start ]
  supports :status => false, :restart => true, :reload => false
end

directory "/srv/tile.openstreetmap.org/tiles" do
  owner "tile"
  group "tile"
  mode 0755
end

template "/etc/renderd.conf" do
  source "renderd.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[apache2]"
  notifies :restart, "service[renderd]"
end

remote_directory "/srv/tile.openstreetmap.org/html" do
  source "html"
  owner "tile"
  group "tile"
  mode 0755
  files_owner "tile"
  files_group "tile"
  files_mode 0644
end

template "/srv/tile.openstreetmap.org/html/index.html" do
  source "index.html.erb"
  owner "tile"
  group "tile"
  mode 0644
end

package "python-cairo"
package "python-mapnik"
package "ttf-dejavu"
package "ttf-unifont"
package "fonts-droid"
package "fonts-sipa-arundina"
package "fonts-sil-padauk"
package "fonts-khmeros"

directory "/srv/tile.openstreetmap.org/cgi-bin" do
  owner "tile"
  group "tile"
  mode 0755
end

template "/srv/tile.openstreetmap.org/cgi-bin/export" do
  source "export.erb"
  owner "tile"
  group "tile"
  mode 0755
  variables :blocks => blocks
end

template "/srv/tile.openstreetmap.org/cgi-bin/debug" do
  source "debug.erb"
  owner "tile"
  group "tile"
  mode 0755
end

template "/etc/cron.hourly/export" do
  source "export.cron.erb"
  owner "root"
  group "root"
  mode 0755
end

directory "/srv/tile.openstreetmap.org/data" do
  owner "tile"
  group "tile"
  mode 0755
end

node[:tile][:data].each do |name,data|
  url = data[:url]
  file = "/srv/tile.openstreetmap.org/data/#{File.basename(url)}"
  directory = "/srv/tile.openstreetmap.org/data/#{data[:directory]}"

  directory directory do
    owner "tile"
    group "tile"
    mode 0755
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

  if data[:processed]
    original = "#{directory}/#{data[:original]}"
    processed = "#{directory}/#{data[:processed]}"

    package "gdal-bin"

    execute processed do
      action :nothing
      command "ogr2ogr #{processed} #{original}"
      user "tile"
      group "tile"
      subscribes :run, "execute[#{file}]", :immediately
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
    else
      action :create_if_missing 
    end

    source url
    owner "tile"
    group "tile"
    mode 0644
    backup false
    notifies :run, "execute[#{file}]", :immediately
    notifies :restart, "service[renderd]"
  end
end

nodejs_package "carto"
nodejs_package "millstone"

directory "/srv/tile.openstreetmap.org/styles" do
  owner "tile"
  group "tile"
  mode 0755
end

node[:tile][:styles].each do |name,details|
  style_directory = "/srv/tile.openstreetmap.org/styles/#{name}"
  tile_directory = "/srv/tile.openstreetmap.org/tiles/#{name}"

  template "/usr/local/bin/update-lowzoom-#{name}" do
    source "update-lowzoom.erb"
    owner "root"
    group "root"
    mode 0755
    variables :style => name
  end

  template "/etc/init.d/update-lowzoom-#{name}" do
    source "update-lowzoom.init.erb"
    owner "root"
    group "root"
    mode 0755
    variables :style => name
  end

  service "update-lowzoom-#{name}" do
    action :disable
    supports :restart => true
  end

  directory tile_directory do
    owner "tile"
    group "tile"
    mode 0755
  end

  details[:tile_directories].each do |directory|
    directory directory[:name] do
      owner "www-data"
      group "www-data"
      mode 0755
    end

    directory[:min_zoom].upto(directory[:max_zoom]) do |zoom|
      directory "#{directory[:name]}/#{zoom}" do
        owner "www-data"
        group "www-data"
        mode 0755
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
    mode 0444
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
    command "carto project.mml > project.xml"
    cwd style_directory
    user "tile"
    group "tile"
    subscribes :run, "git[#{style_directory}]"
    notifies :restart, "service[renderd]", :immediately
    notifies :restart, "service[update-lowzoom-#{name}]"
  end
end

package "postgis"

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

[ "geography_columns",
  "planet_osm_nodes",
  "planet_osm_rels",
  "planet_osm_ways",
  "raster_columns", 
  "raster_overviews", 
  "spatial_ref_sys" ].each do |table|
  postgresql_table table do
    cluster node[:tile][:database][:cluster]
    database "gis"
    owner "tile"
    permissions "tile" => :all
  end
end

[ "geometry_columns", 
  "planet_osm_line", 
  "planet_osm_point", 
  "planet_osm_polygon", 
  "planet_osm_roads" ].each do |table|
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

file node[:tile][:node_file] do
  owner "tile"
  group "www-data"
  mode 0640
end

directory "/var/log/tile" do
  owner "tile"
  group "tile"
  mode 0755
end

package "osm2pgsql"
package "osmosis"

package "ruby"
package "rubygems"

package "libproj-dev"
package "libxml2-dev"

gem_package "proj4rb"
gem_package "libxml-ruby"
gem_package "mmap"

remote_directory "/usr/local/lib/site_ruby" do
  source "ruby"
  owner "root"
  group "root"
  mode 0755
  files_owner "root"
  files_group "root"
  files_mode 0644
end

template "/usr/local/bin/expire-tiles" do
  source "expire-tiles.erb"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/sudoers.d/tile" do
  source "sudoers.erb"
  owner "root"
  group "root"
  mode 0440
end

directory "/var/lib/replicate" do
  owner "tile"
  group "tile"
  mode 0755
end

template "/var/lib/replicate/configuration.txt" do
  source "replicate.configuration.erb"
  owner "tile"
  group "tile"
  mode 0644
end

template "/usr/local/bin/replicate" do
  source "replicate.erb"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/init.d/replicate" do
  source "replicate.init.erb"
  owner "root"
  group "root"
  mode 0755
end

service "replicate" do
  action [ :enable, :start ]
  supports :restart => true
  subscribes :restart, "template[/usr/local/bin/replicate]"
  subscribes :restart, "template[/etc/init.d/replicate]"
end

template "/etc/logrotate.d/replicate" do
  source "replicate.logrotate.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/usr/local/bin/render-lowzoom" do
  source "render-lowzoom.erb"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/cron.d/render-lowzoom" do
  source "render-lowzoom.cron.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/rsyslog.d/20-renderd.conf" do
  source "renderd.rsyslog.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[rsyslog]"
end

package "liblockfile-simple-perl"
package "libfilesys-df-perl"

template "/usr/local/bin/cleanup-tiles" do
  source "cleanup-tiles.erb"
  owner "root"
  group "root"
  mode 0755
end

tile_directories = node[:tile][:styles].collect do |name,style|
  style[:tile_directories].collect { |directory| directory[:name] }
end.flatten.sort.uniq

template "/etc/cron.d/cleanup-tiles" do
  source "cleanup-tiles.cron.erb"
  owner "root"
  group "root"
  mode 0644
  variables :directories => tile_directories
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

munin_plugin "replication_delay" do
  conf "munin.erb"
end
