#
# Cookbook:: imagery
# Recipe:: bg_imagery
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

imagery_site "bg-imagery.openstreetmap.org" do
  title "OpenStreetMap - Bulgaria - Aerial Imagery"
  aliases ["bg-imagery.osm.org"]
  bbox [[41.235, 22.357], [44.215, 28.608]]
end

imagery_layer "maf-orthophoto-latest" do
  site "bg-imagery.openstreetmap.org"
  title "Bulgaria MAF Orthophoto Latest"
  source "/store/imagery/bg/maf-orthophoto-map/maf-orthophoto.vrt"
  copyright "(c) Ministry of Agriculture and Food of Bulgaria"
  max_zoom 20
  default_layer true
end
