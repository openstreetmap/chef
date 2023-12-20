#
# Cookbook:: podman
# Resource:: podman_site
#
# Copyright:: 2023, OpenStreetMap Foundation
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
property :image, String, :required => true
property :port, Integer, :default => 8080
property :aliases, :kind_of => Array, :default => []
property :environment, Hash, :default => {}

action :create do
  podman_service new_resource.site do
    description "Container service for #{new_resource.site}"
    image new_resource.image
    ports external_port => new_resource.port
    environment new_resource.environment
  end

  ssl_certificate new_resource.site do
    domains Array(new_resource.site) + new_resource.aliases
  end

  apache_site new_resource.site do
    cookbook "podman"
    template "apache.erb"
    variables :port => external_port, :aliases => new_resource.aliases
  end
end

action :delete do
  apache_site new_resource.site do
    action [:disable, :delete]
  end

  podman_service new_resource.site do
    action :delete
  end

  node.rm_normal(:podman, :ports, new_resource.site)
end

action_class do
  def ports_file
    "#{Chef::Config[:file_cache_path]}/podman-ports.yml"
  end

  def ports
    @ports ||= if ::File.exist?(ports_file)
                 YAML.safe_load(::File.read(ports_file))
               else
                 {}
               end
  end

  def external_port
    unless ports.include?(new_resource.site)
      port = 40000

      port += 1 while ports.values.include?(port)

      ports[new_resource.site] = port

      ::File.write(ports_file, YAML.dump(ports))
    end

    ports[new_resource.site]
  end
end

def after_created
  notifies :reload, "service[apache2]"
end
