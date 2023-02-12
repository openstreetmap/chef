#
# Cookbook:: switch2osm
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

include_recipe "apache"
include_recipe "podman"

docker_external_port = 8093

podman_service "switch2osm.org" do
  description "Container service for switch2osm.org"
  image "ghcr.io/switch2osm/switch2osm:latest"
  ports docker_external_port => "8080"
end

ssl_certificate "switch2osm.org" do
  domains ["switch2osm.org",
           "www.switch2osm.org", "switch2osm.com", "www.switch2osm.com"]
  notifies :reload, "service[apache2]"
end

apache_module "proxy_http"

apache_site "switch2osm.org" do
  template "apache.erb"
  variables :docker_external_port => docker_external_port, :aliases => ["www.switch2osm.org", "switch2osm.com", "www.switch2osm.com"]
end
