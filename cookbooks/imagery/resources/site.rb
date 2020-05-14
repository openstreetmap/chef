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

default_action :create

property :site, String, :name_property => true
property :title, String, :required => [:create]
property :aliases, [String, Array], :default => []
property :bbox, Array, :required => [:create]

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

  layers = Dir.glob("/srv/imagery/layers/#{new_resource.site}/*.yml").collect do |path|
    YAML.safe_load(::File.read(path), [Symbol])
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

  %w[0 1 2 3 4 5 6 7].each do |index|
    systemd_service "mapserv-fcgi-#{new_resource.site}-#{index}" do
      description "Map server for #{new_resource.site} layer"
      environment "MS_MAP_PATTERN" => "^/srv/imagery/mapserver/",
                  "MS_DEBUGLEVEL" => "0",
                  "MS_ERRORFILE" => "stderr",
                  "GDAL_CACHEMAX" => "512"
      limit_nofile 16384
      limit_cpu 180
      memory_max "4G"
      user "imagery"
      group "imagery"
      exec_start_pre "/bin/rm -f /run/mapserver-fastcgi/layer-#{new_resource.site}-#{index}.socket"
      exec_start "/usr/bin/spawn-fcgi -n -b 8192 -s /run/mapserver-fastcgi/layer-#{new_resource.site}-#{index}.socket -M 0666 -P /run/mapserver-fastcgi/layer-#{new_resource.site}-#{index}.pid -- /usr/lib/cgi-bin/mapserv"
      private_tmp true
      private_devices true
      private_network true
      protect_system "full"
      protect_home true
      no_new_privileges true
      restart "always"
      pid_file "/run/mapserver-fastcgi/layer-#{new_resource.site}-#{index}.pid"
    end

    service "mapserv-fcgi-#{new_resource.site}-#{index}" do
      provider Chef::Provider::Service::Systemd
      action [:enable, :start]
      supports :status => true, :restart => true, :reload => false
      subscribes :restart, "systemd_service[mapserv-fcgi-#{new_resource.site}-#{index}]"
    end
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
  %w[0 1 2 3 4 5 6 7].each do |index|
    service "mapserv-fcgi-#{new_resource.site}-#{index}" do
      provider Chef::Provider::Service::Systemd
      action [:stop, :disable]
    end

    systemd_service "mapserv-fcgi-#{new_resource.site}-#{index}" do
      action :delete
    end
  end

  nginx_site new_resource.site do
    action :delete
  end
end

def after_created
  notifies :reload, "service[nginx]"
end
