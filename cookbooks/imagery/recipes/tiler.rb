#
# Cookbook:: imagery
# Recipe:: tiler
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

include_recipe "imagery"
include_recipe "podman"

directory "/store/imagery" do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

# FIXME: until upstream supports arm64 images: https://github.com/developmentseed/titiler/pull/740
container_image = if arm?
                    "ghcr.io/firefishy/titiler:latest"
                  else
                    "ghcr.io/developmentseed/titiler:latest"
                  end

podman_service "titiler" do
  description "Container service for titiler"
  image container_image
  volume :"/store/imagery"       => "/store/imagery",
         :"/srv/imagery/sockets" => "/sockets"
  environment :BIND                                => "unix:/sockets/titiler.sock",
              :WORKERS_PER_CORE                    => 1,
              :GDAL_CACHEMAX                       => 200,
              :GDAL_BAND_BLOCK_CACHE               => "HASHSET",
              :GDAL_DISABLE_READDIR_ON_OPEN        => "EMPTY_DIR",
              :GDAL_INGESTED_BYTES_AT_OPEN         => 32768,
              :GDAL_HTTP_MERGE_CONSECUTIVE_RANGES  => "YES",
              :GDAL_HTTP_MULTIPLEX                 => "YES",
              :GDAL_HTTP_VERSION                   => 2,
              :VSI_CACHE                           => "TRUE",
              :VSI_CACHE_SIZE                      => 5000000,
              :TITILER_API_ROOT_PATH               => "/api/v1/titiler",
              :FORWARDED_ALLOW_IPS                 => "*" # https://docs.gunicorn.org/en/latest/settings.html#forwarded-allow-ips
end

systemd_service "titiler-restart" do
  type "simple"
  user "root"
  exec_start "/bin/systemctl try-restart titiler.service"
  sandbox true
  restrict_address_families "AF_UNIX"
end

systemd_timer "titiler-restart" do
  on_boot_sec "6h"
  on_unit_inactive_sec "12h"
end

service "titiler-restart.timer" do
  action [:enable, :start]
end

directory "/var/cache/nginx-cache" do
  owner "www-data"
  group "www-data"
  mode "755"
end

ssl_certificate "tiler.openstreetmap.org" do
  domains "tiler.openstreetmap.org"
  notifies :reload, "service[nginx]"
end

nginx_site "tiler.openstreetmap.org" do
  template "nginx_titiler.conf.erb"
  variables :aliases => ["tiler.osm.org"]
end
