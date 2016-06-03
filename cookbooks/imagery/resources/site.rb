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

property :name, String
property :title, String, :required => true
property :aliases, [String, Array], :default => []
property :bbox, Array, :required => true

action :create do
  directory "/srv/#{name}" do
    user "root"
    group "root"
    mode 0755
  end

  directory "/srv/imagery/layers/#{name}" do
    user "root"
    group "root"
    mode 0755
    recursive true
  end

  directory "/srv/imagery/overlays/#{name}" do
    user "root"
    group "root"
    mode 0755
    recursive true
  end

  template "/srv/#{name}/index.html" do
    source "index.html.erb"
    user "root"
    group "root"
    mode 0644
    variables :title => title
  end

  cookbook_file "/srv/#{name}/imagery.css" do
    source "imagery.css"
    user "root"
    group "root"
    mode 0644
  end

  layers = Dir.glob("/srv/imagery/layers/#{name}/*.yml").collect do |path|
    YAML.load(::File.read(path))
  end

  template "/srv/#{name}/imagery.js" do
    source "imagery.js.erb"
    user "root"
    group "root"
    mode 0644
    variables :bbox => bbox, :layers => layers
  end

  nginx_site name do
    template "nginx_imagery.conf.erb"
    directory "/srv/imagery/#{name}"
    restart_nginx false
    variables new_resource.to_hash
  end
end

def after_created
  notifies :restart, "service[nginx]"
end
