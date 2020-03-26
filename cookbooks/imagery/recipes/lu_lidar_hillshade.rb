#
# Cookbook:: imagery
# Recipe:: lu_lidar_hillshade
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

include_recipe "imagery"

imagery_site "lidar-hillshade-2019.openstreetmap.lu" do
  title "OpenStreetMap - Lidar Hillshade 2019"
  bbox [[49.38, 5.64], [50.2, 6.64]]
end

imagery_layer "lidar-hillshade-2019" do
  site "lidar-hillshade-2019.openstreetmap.lu"
  default_layer true
  projection "EPSG:3857"
  source "/data/imagery/lu/lidar-hillshade/lu-lidar-2019-epsg3857.tif"
  max_zoom 21
  title "Lidar Hillshading"
  copyright '&copy; 2019 <a href="https://data.public.lu/fr/datasets/lidar-2019-releve-3d-du-territoire-luxembourgeois">Administration du Cadastre et de la Topographie Luxembourg</a>, CC0'
end
