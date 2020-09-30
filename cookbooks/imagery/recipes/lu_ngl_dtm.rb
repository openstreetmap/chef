#
# Cookbook:: imagery
# Recipe:: lu_ngl_dtm
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

imagery_site "ana-dtm-2017.openstreetmap.lu" do
  title "OpenStreetMap - ANA DTM 2017"
  bbox [[49.38, 5.64], [50.2, 6.64]]
end

imagery_layer "ana_dtm_2017" do
  site "ana-dtm-2017.openstreetmap.lu"
  projection "EPSG:3857"
  source "/data/imagery/lu/LUREF_NGL/lu_color_relief-epsg3857-compress.tif"
  max_zoom 21
  title "DTM"
  copyright '&copy; 2017 <a href="https://data.public.lu/fr/datasets/digital-terrain-model-high-dem-resolution/">Administration de la Navigation A&eacute;rienne Luxembourg</a>, CC0'
end

imagery_layer "ana_dtm_2017_hillshading" do
  site "ana-dtm-2017.openstreetmap.lu"
  projection "EPSG:3857"
  source "/data/imagery/lu/LUREF_NGL/lu_hillshade_2017-epsg-3857-compress.tif"
  max_zoom 21
  title "DTM Hillshading (single light source)"
  copyright '&copy; 2017 <a href="https://data.public.lu/fr/datasets/digital-terrain-model-high-dem-resolution/">Administration de la Navigation A&eacute;rienne Luxembourg</a>, CC0'
end

imagery_layer "ana_dtm_2017_hillshading_multi" do
  site "ana-dtm-2017.openstreetmap.lu"
  default_layer true
  projection "EPSG:3857"
  source "/data/imagery/lu/LUREF_NGL/ANA_LUREF_NGL_DTM_hillshade_multi_epsg3857.tif"
  max_zoom 21
  title "DTM Hillshading (multidirectional)"
  copyright 'DEM 2017 <a href="https://data.public.lu/fr/datasets/digital-terrain-model-high-dem-resolution/">Administration de la Navigation A&eacute;rienne Luxembourg</a>, hillshading <a href="https://twitter.com/dmoraisferreira">David Morais Ferreira</a> &amp; <a href="https://twitter.com/grischard">Guillaume Rischard</a> CC0'
end
