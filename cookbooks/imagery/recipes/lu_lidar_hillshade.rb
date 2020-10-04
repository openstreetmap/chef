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

# Delete borken layers like this

imagery_layer "classy_mappers_delight_lidar_hillshade_2019" do
  site "lidar-hillshade-2019.openstreetmap.lu"
  action :delete
end

imagery_layer "mappers_delight_lidar_dem_2019" do
  site "lidar-hillshade-2019.openstreetmap.lu"
  projection "EPSG:3857"
  source "/data/imagery/lu/lidar-hillshade/dem-3857.tif"
  max_zoom 20
  title "OpenStreetMap.lu Mapper's Delight 2019 Lidar DEM"
  copyright 'Lidar data 2019 <a href="https://data.public.lu/fr/datasets/lidar-2019-releve-3d-du-territoire-luxembourgeois">Administration du Cadastre et de la Topographie Luxembourg</a>, DEM <a href="https://twitter.com/grischard">Guillaume Rischard</a>, CC0'
end

imagery_layer "mappers_delight_lidar_hillshade_2019_reprojected" do
  site "lidar-hillshade-2019.openstreetmap.lu"
  default_layer true
  projection "EPSG:3857"
  source "/data/imagery/lu/lidar-hillshade/lu_hillshade_2019-3857.tif"
  max_zoom 20
  title "OpenStreetMap.lu Mapper's Delight 2019 Lidar Hillshading"
  copyright 'Lidar data 2019 <a href="https://data.public.lu/fr/datasets/lidar-2019-releve-3d-du-territoire-luxembourgeois">Administration du Cadastre et de la Topographie Luxembourg</a>, DEM and hillshading <a href="https://twitter.com/grischard">Guillaume Rischard</a>, CC0'
end

imagery_layer "mappers_delight_lidar_hillshade_2019_withunclassified" do
  site "lidar-hillshade-2019.openstreetmap.lu"
  projection "EPSG:3857"
  source "/data/imagery/lu/lidar-hillshade/classy-hillshade.tif"
  max_zoom 20
  title "OpenStreetMap.lu Mapper's Delight 2019 Lidar Hillshading with unclassified points"
  copyright 'Lidar data 2019 <a href="https://data.public.lu/fr/datasets/lidar-2019-releve-3d-du-territoire-luxembourgeois">Administration du Cadastre et de la Topographie Luxembourg</a>, DEM and hillshading <a href="https://twitter.com/grischard">Guillaume Rischard</a>, CC0'
end