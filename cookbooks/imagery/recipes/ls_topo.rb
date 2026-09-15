#
# Cookbook:: imagery
# Recipe:: lesotho_topo
#
# Copyright:: 2026, OpenStreetMap Foundation
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

imagery_site "lesotho-topo.openstreetmap.org.za" do
  title "OpenStreetMap - Lesotho - Topographic Series"
  aliases ["lesotho-topo.osm.org.za"]
  bbox [[-30.677, 27.011], [-28.572, 29.468]]
end

imagery_layer "ls_topo_50k" do
  site "lesotho-topo.openstreetmap.org.za"
  title "Lesotho Topo 50k"
  projection "EPSG:3857"
  source "/store/imagery/ls/50k-topo/combined.webp.google.r_lanczos.bs_256.aligned.cog.tif"
  title "Lesotho Topographic Series 50k"
  copyright "Surveyor-General, Lesotho"
  default_layer true
end
