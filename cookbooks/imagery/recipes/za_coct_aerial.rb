#
# Cookbook Name:: imagery
# Recipe:: za_coct_aerial
#
# Copyright 2016, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "imagery"

imagery_site "coct.aerial.openstreetmap.org.za" do
  title "OpenStreetMap - City of Cape Town Aerial"
  aliases ["coct.aerial.osm.org.za"]
  bbox [[-34.365, 18.290], [-33.465, 19.015]]
end

imagery_layer "za_coct_aerial_2015" do
  projection "EPSG:3857"
  site "coct.aerial.openstreetmap.org.za"
  title "City of Cape Town Aerial - 2015 (OSM USE ONLY)"
  source "/data/imagery/za/coct/2015-epsg-3857.tif"
  copyright 'Copyright &copy; 2015 <a href="https://www.capetown.gov.za/">City of Cape Town</a>'
  background_colour "0 0 0"
  extension "jpeg"
  default_layer true
  max_zoom 21
end

imagery_layer "za_coct_aerial_2015_hart94" do
  projection "EPSG:3857"
  site "coct.aerial.openstreetmap.org.za"
  title "City of Cape Town Aerial - 2015 (Hart94 Reproj) (OSM USE ONLY)"
  source "/data/imagery/za/coct/2015-hart94-epsg-3857.tif"
  copyright 'Copyright &copy; 2015 <a href="https://www.capetown.gov.za/">City of Cape Town</a>'
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 21
end

# imagery_layer "za_coct_aerial_2013" do
#   projection "EPSG:3857"
#   site "coct.aerial.openstreetmap.org.za"
#   title "City of Cape Town Aerial - 2013 (OSM USE ONLY)"
#   source "/data/imagery/za/coct/2013-tif-epsg-3857.vrt"
#   copyright 'Copyright &copy; 2013 <a href="https://www.capetown.gov.za/">City of Cape Town</a>'
#   max_zoom 21
# end
