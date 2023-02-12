#
# Cookbook:: foundation
# Recipe:: owg
#
# Copyright:: 2016, OpenStreetMap Foundation
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

docker_external_port = 8091

podman_service "operations.osmfoundation.org" do
  description "Container service for operations.osmfoundation.org"
  image "ghcr.io/openstreetmap/owg-website:latest"
  ports docker_external_port => "8080"
end

ssl_certificate "operations.osmfoundation.org" do
  domains ["operations.osmfoundation.org", "operations.openstreetmap.org", "operations.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_module "proxy_http"

apache_site "operations.osmfoundation.org" do
  template "apache.owg.erb"
  variables :docker_external_port => docker_external_port, :aliases => ["operations.openstreetmap.org", "operations.osm.org"]
end
