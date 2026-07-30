#
# Cookbook:: imagery
# Recipe:: br_imagery
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

imagery_site "br-imagery.openstreetmap.org" do
  title "OpenStreetMap - Brazil - Aerial Imagery"
  aliases ["br-imagery.osm.org"]
  bbox [[-23.9813, -46.6594], [-23.6398, -46.4042]]
end

imagery_layer "ibge-aerial-2021" do
  site "br-imagery.openstreetmap.org"
  title "Brazil IBGE Aerial Imagery 2021"
  source "/store/imagery/br/ibge-aerial-2021/ibge-aerial-2021.webp.google.r_bilinear.bs_256.aligned.cog.tif"
  copyright '(c) <a href="https://www.ibge.gov.br/">IBGE</a>'
  projection "EPSG:3857"
  max_zoom 21
  default_layer true
  revision 1
end
