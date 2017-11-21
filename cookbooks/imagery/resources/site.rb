#
# Cookbook Name:: imagery
# Resource:: imagery_site
#
# Copyright 2016, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
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
property :title, String, :required => true
property :aliases, [String, Array], :default => []
property :bbox, Array, :required => true

action :create do
  directory "/srv/#{new_resource.site}" do
    user "root"
    group "root"
    mode 0o755
  end

  directory "/srv/imagery/layers/#{new_resource.site}" do
    user "root"
    group "root"
    mode 0o755
    recursive true
  end

  directory "/srv/imagery/overlays/#{new_resource.site}" do
    user "root"
    group "root"
    mode 0o755
    recursive true
  end

  declare_resource :template, "/srv/#{new_resource.site}/index.html" do
    source "index.html.erb"
    user "root"
    group "root"
    mode 0o644
    variables :title => title
  end

  cookbook_file "/srv/#{new_resource.site}/imagery.css" do
    source "imagery.css"
    user "root"
    group "root"
    mode 0o644
  end

  cookbook_file "/srv/#{new_resource.site}/clientaccesspolicy.xml" do
    source "clientaccesspolicy.xml"
    user "root"
    group "root"
    mode 0o644
  end

  cookbook_file "/srv/#{new_resource.site}/crossdomain.xml" do
    source "crossdomain.xml"
    user "root"
    group "root"
    mode 0o644
  end

  layers = Dir.glob("/srv/imagery/layers/#{new_resource.site}/*.yml").collect do |path|
    YAML.safe_load(::File.read(path), [Symbol])
  end

  declare_resource :template, "/srv/#{new_resource.site}/imagery.js" do
    source "imagery.js.erb"
    user "root"
    group "root"
    mode 0o644
    variables :bbox => new_resource.bbox, :layers => layers
  end

  base_domains = [new_resource.site] + Array(new_resource.aliases)
  tile_domains = base_domains.flat_map { |d| [d, "a.#{d}", "b.#{d}", "c.#{d}"] }

  ssl_certificate new_resource.site do
    domains tile_domains
  end

  resolvers = node[:networking][:nameservers].map do |resolver|
    IPAddr.new(resolver).ipv6? ? "[#{resolver}]" : resolver
  end

  nginx_site new_resource.site do
    template "nginx_imagery.conf.erb"
    directory "/srv/imagery/#{new_resource.site}"
    restart_nginx false
    variables new_resource.to_hash.merge(:resolvers => resolvers)
  end
end

def after_created
  notifies :reload, "service[nginx]"
end
