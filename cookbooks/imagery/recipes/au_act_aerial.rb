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

imagery_layer "act_aerial_imagery_latest" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery latest"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_Current/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_Current/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> (c) Australian Capital Territory and MetroMap. "
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
  default_layer true
end

imagery_layer "act_aerial_imagery_202505" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202505"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/2025_05_urban_75mm/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202411/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> (c) Australian Capital Territory and MetroMap. "
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end

imagery_layer "act_aerial_imagery_202503" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202503"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/2025_03_urban_75mm/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202411/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> (c) Australian Capital Territory and MetroMap. "
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end

imagery_layer "act_aerial_imagery_202411" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202411"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/2024_11_full_75mm/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202411/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> (c) Australian Capital Territory and MetroMap. "
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end

imagery_layer "act_aerial_imagery_202409" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202409"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/2024_09_urban_75mm/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/2024_09_urban_75mm/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> (c) Australian Capital Territory and MetroMap. "
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end

imagery_layer "act_aerial_imagery_202402" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202402"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/2024_02_urban_75mm/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/2024_09_urban_75mm/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> (c) Australian Capital Territory and MetroMap. "
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end

imagery_layer "act_aerial_imagery_202311" do
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202311"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/2023_11_full_75mm/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202311/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> (c) Australian Capital Territory and MetroMap. "
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end

# 2025 August - No longer available - appears password protected
imagery_layer "act_aerial_imagery_202305" do
  action :delete
  site "act-imagery.openstreetmap.org"
  title "ACT Aerial Imagery 202305"
  projection "EPSG:7855"
  source "https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202305/MapServer/WMTS/1.0.0/WMTSCapabilities.xml"
  # attribution per https://www.actmapi.act.gov.au/terms-and-conditions and https://tiles.arcgis.com/tiles/E5n4f1VY84i0xSjy/arcgis/rest/services/ACT_Aerial_Imagery_202305/MapServer/
  copyright "ACT Imagery from <a href='https://www.actmapi.act.gov.au/home'>ACTmapi</a> (c) Australian Capital Territory and MetroMap. "
  background_colour "0 0 0"
  extension "jpeg"
  max_zoom 22
end
