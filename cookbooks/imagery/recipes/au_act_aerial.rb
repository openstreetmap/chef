#
# Cookbook:: imagery
# Recipe:: au_act_aerial
#
# Copyright:: 2025, OpenStreetMap Foundation
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

imagery_site "act-imagery.openstreetmap.org" do
  title "OpenStreetMap - ACT Imagery"
  aliases ["act-imagery.osm.org"]
  # https://leafletjs.com/reference.html#latlngbounds format
  # [[south, west], [north, east]]
  bbox [[-35.942, 148.729], [-35.117, 149.430]]
end

imagery_layer "act_aerial_imagery_202409" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202409"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202409/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202409/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> ©Australian Capital Territory and MetroMap."
  default_layer true
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end

imagery_layer "act_aerial_imagery_202311" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202311"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202311/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202311/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> ©Australian Capital Territory and MetroMap."
  default_layer true
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end

imagery_layer "act_aerial_imagery_202305" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202305"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202305/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202305/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> ©Australian Capital Territory and MetroMap."
  default_layer true
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end
