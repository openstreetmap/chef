#
# Cookbook:: imagery
# Resource:: imagery_layer
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

property :layer, String, :name_property => true
property :site, String, :required => true
property :source, String, :required => [:create]
property :root_layer, [true, false], :default => false
property :title, String
property :copyright, String, :default => "Copyright"
property :projection, String, :default => "EPSG:3857"
property :palette, String
property :extent, String
property :background_colour, String
property :resample, String, :default => "average"
property :imagemode, String
property :extension, String, :default => "png"
property :max_zoom, Integer, :default => 18
property :url_aliases, [String, Array], :default => []
property :revision, Integer, :default => 0
property :overlay, [true, false], :default => false
property :default_layer, [true, false], :default => false

action :create do
  file "/srv/imagery/layers/#{new_resource.site}/#{new_resource.layer}.yml" do
    owner "root"
    group "root"
    mode "644"
    content YAML.dump(:name => new_resource.layer,
                      :title => new_resource.title || new_resource.layer,
                      :url => "//{s}.#{new_resource.site}/layer/#{new_resource.layer}/{z}/{x}/{y}.png",
                      :attribution => new_resource.copyright,
                      :default => new_resource.default_layer,
                      :maxZoom => new_resource.max_zoom,
                      :overlay => new_resource.overlay)
  end

  template "/srv/imagery/mapserver/layer-#{new_resource.layer}.map" do
    cookbook "imagery"
    source "mapserver.map.erb"
    owner "root"
    group "root"
    mode "644"
    variables new_resource.to_hash
  end

  # Disable legacy service
  service "mapserv-fcgi-#{new_resource.layer}" do
    action [:stop, :disable]
  end

  # Remove legacy service
  systemd_service "mapserv-fcgi-#{new_resource.layer}" do
    action :delete
  end

  directory "/srv/imagery/nginx/#{new_resource.site}" do
    owner "root"
    group "root"
    mode "755"
    recursive true
  end

  template "/srv/imagery/nginx/#{new_resource.site}/layer-#{new_resource.layer}.conf" do
    cookbook "imagery"
    source "nginx_imagery_layer_fragment.conf.erb"
    owner "root"
    group "root"
    mode "644"
    variables new_resource.to_hash
  end
end

action :delete do
  file "/srv/imagery/layers/#{new_resource.site}/#{new_resource.layer}.yml" do
    action :delete
  end

  service "mapserv-fcgi-layer-#{new_resource.layer}" do
    action [:stop, :disable]
  end

  file "/srv/imagery/mapserver/layer-#{new_resource.layer}.map" do
    action :delete
  end

  systemd_service "mapserv-fcgi-#{new_resource.layer}" do
    action :delete
  end

  file "/srv/imagery/nginx/#{new_resource.site}/layer-#{new_resource.layer}.conf" do
    action :delete
  end
end

def after_created
  notifies :create, "imagery_site[#{site}]"
  notifies :restart, "service[nginx]"
end
