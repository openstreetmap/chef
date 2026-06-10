#
# Cookbook:: imagery
# Recipe:: mw_dos_topo
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

imagery_site "malawi-topo.openstreetmap.org.za" do
  title "OpenStreetMap - MW - Topographic Series"
  aliases ["malawi-topo.osm.org.za"]
  bbox [[-17.123456, 33.123456], [-14.123456, 35.123456]]
end

imagery_layer "mw_dos_topo_50k" do
  site "malawi-topo.openstreetmap.org.za"
  title "MW Topo 50k"
  projection "EPSG:3857"
  source "/store/imagery/mw/50k-topo/combined.webp.google.r_lanczos.bs_256.aligned.cog.tif"
  copyright "Directorate of Overseas Surveys (DOS)"
  default_layer true
  revision 1
end
