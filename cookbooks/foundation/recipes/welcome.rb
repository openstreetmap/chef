#
# Cookbook:: foundation
# Recipe:: welcome
#
# Copyright:: 2023, OpenStreetMap Foundation
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
include_recipe "docker"

docker_external_port = 8090

systemd_service "docker_welcome-mat" do
  description "Docker service for welcome.openstreetmap.org"
  requires "docker.service"
  exec_start_pre [
    "-/usr/bin/docker kill welcome-mat",
    "-/usr/bin/docker rm welcome-mat"
  ]
  exec_start "/usr/bin/docker run --rm --name=welcome-mat -p #{docker_external_port}:80 ghcr.io/osmfoundation/welcome-mat:latest"
  exec_stop [
    "-/usr/bin/docker kill welcome-mat",
    "-/usr/bin/docker rm welcome-mat"
  ]
  restart "always"
end

# FIXME: this should be a docker_image resource
# The image pull is handled by the service but tests will fail if the pull delays the container start
execute "docker_pull_welcome_mat" do
  command "/usr/bin/docker pull ghcr.io/osmfoundation/welcome-mat:latest"
  action :nothing
  subscribes :run, "systemd_service[docker_welcome-mat]"
end

service "docker_welcome-mat" do
  action [:enable, :start]
  subscribes :restart, "systemd_service[docker_welcome-mat]"
end

ssl_certificate "welcome.openstreetmap.org" do
  domains ["welcome.openstreetmap.org", "welcome.osm.org"]
  notifies :reload, "service[apache2]"
end

apache_module "proxy_http"

apache_site "welcome.openstreetmap.org" do
  template "apache.welcome.erb"
  variables :docker_external_port => docker_external_port, :aliases => ["welcome.osm.org"]
end
