#
# Cookbook:: imagery
# Resource:: imagery_site
#
# Copyright:: 2016, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "yaml"

unified_mode true

default_action :create

property :site, String, :name_property => true
property :title, String, :required => [:create]
property :aliases, [String, Array], :default => []
property :bbox, Array, :required => [:create]
property :uses_tiler, [true, false], :default => false

action :create do
  directory "/srv/#{new_resource.site}" do
    user "root"
    group "root"
    mode "755"
  end

  directory "/srv/imagery/layers/#{new_resource.site}" do
    user "root"
    group "root"
    mode "755"
    recursive true
  end

  directory "/srv/imagery/overlays/#{new_resource.site}" do
    user "root"
    group "root"
    mode "755"
    recursive true
  end

  declare_resource :template, "/srv/#{new_resource.site}/index.html" do
    source "index.html.erb"
    user "root"
    group "root"
    mode "644"
    variables :title => new_resource.title
  end

  cookbook_file "/srv/#{new_resource.site}/robots.txt" do
    source "robots.txt"
    user "root"
    group "root"
    mode "644"
  end

  cookbook_file "/srv/#{new_resource.site}/imagery.css" do
    source "imagery.css"
    user "root"
    group "root"
    mode "644"
  end

  cookbook_file "/srv/#{new_resource.site}/clientaccesspolicy.xml" do
    source "clientaccesspolicy.xml"
    user "root"
    group "root"
    mode "644"
  end

  cookbook_file "/srv/#{new_resource.site}/crossdomain.xml" do
    source "crossdomain.xml"
    user "root"
    group "root"
    mode "644"
  end

  cookbook_file "/srv/#{new_resource.site}/transparent.png" do
    source "transparent.png"
    user "root"
    group "root"
    mode "644"
  end

  layers = Dir.glob("/srv/imagery/layers/#{new_resource.site}/*.yml").collect do |path|
    YAML.safe_load_file(path, :permitted_classes => [Symbol])
  end

  declare_resource :template, "/srv/#{new_resource.site}/imagery.js" do
    source "imagery.js.erb"
    user "root"
    group "root"
    mode "644"
    variables :bbox => new_resource.bbox, :layers => layers
  end

  base_domains = [new_resource.site] + Array(new_resource.aliases)
  tile_domains = base_domains.flat_map { |d| [d, "a.#{d}", "b.#{d}", "c.#{d}"] }

  systemd_service "mapserv-fcgi-#{new_resource.site}" do
    description "Map server for #{new_resource.site} layer"
    environment "MS_DEBUGLEVEL" => "0",
                "MS_ERRORFILE" => "stderr",
                "GDAL_CACHEMAX" => "128",
                "GDAL_HTTP_TCP_KEEPALIVE" => "YES",
                "GDAL_HTTP_VERSION" => "2TLS",
                "GDAL_ENABLE_WMS_CACHE" => "NO",
                "LD_PRELOAD" => "libtcmalloc_minimal.so.4"
    limit_nofile 16384
    limit_core 0
    user "imagery"
    group "imagery"
    exec_start "/usr/bin/multiwatch -f 8 --signal=TERM -- /usr/lib/cgi-bin/mapserv"
    standard_input "socket"
    sandbox :enable_network => true
    restrict_address_families "AF_UNIX"
    timeout_stop_sec 60
    not_if { new_resource.uses_tiler }
  end

  systemd_socket "mapserv-fcgi-#{new_resource.site}" do
    description "Map server for #{new_resource.site} layer socket"
    socket_user "imagery"
    socket_group "imagery"
    listen_stream "/run/mapserver-fastcgi/layer-#{new_resource.site}.socket"
    not_if { new_resource.uses_tiler }
  end

  # Ensure service is stopped because otherwise the socket cannot reload
  service "mapserv-fcgi-#{new_resource.site}" do
    provider Chef::Provider::Service::Systemd
    action :nothing
    subscribes :stop, "systemd_service[mapserv-fcgi-#{new_resource.site}]"
    subscribes :stop, "systemd_socket[mapserv-fcgi-#{new_resource.site}]"
    not_if { new_resource.uses_tiler }
  end

  systemd_unit "mapserv-fcgi-#{new_resource.site}.socket" do
    action [:enable, :start]
    subscribes :restart, "systemd_socket[mapserv-fcgi-#{new_resource.site}]"
    not_if { new_resource.uses_tiler }
  end

  # mapserver leaks memory, so restart it regularly. It is activated automatically by socket
  systemd_service "mapserv-fcgi-#{new_resource.site}-stop" do
    type "simple"
    user "root"
    exec_start "/bin/systemctl --quiet stop mapserv-fcgi-#{new_resource.site}.service"
    sandbox true
    restrict_address_families "AF_UNIX"
    not_if { new_resource.uses_tiler }
  end

  systemd_timer "mapserv-fcgi-#{new_resource.site}-stop" do
    on_boot_sec "10m"
    on_unit_inactive_sec "6h"
    randomized_delay_sec "20m"
    not_if { new_resource.uses_tiler }
  end

  service "mapserv-fcgi-#{new_resource.site}-stop.timer" do
    action [:enable, :start]
    not_if { new_resource.uses_tiler }
  end

  ssl_certificate new_resource.site do
    domains tile_domains
  end

  nginx_site new_resource.site do
    template "nginx_imagery.conf.erb"
    directory "/srv/imagery/#{new_resource.site}"
    variables new_resource.to_hash
  end
end

action :delete do
  service "mapserv-fcgi-#{new_resource.site}" do
    provider Chef::Provider::Service::Systemd
    action [:stop, :disable]
    not_if { new_resource.uses_tiler }
  end

  systemd_service "mapserv-fcgi-#{new_resource.site}" do
    action :delete
    not_if { new_resource.uses_tiler }
  end

  nginx_site new_resource.site do
    action :delete
  end
end

def after_created
  notifies :reload, "service[nginx]"
end
