#
# Cookbook:: imagery
# Recipe:: zimbabwe_topo
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

imagery_site "zimbabwe-topo.openstreetmap.org.za" do
  title "OpenStreetMap - Zimbabwe - Topographic Series"
  aliases ["zimbabwe-topo.osm.org.za"]
  bbox [[-22.2696370, 25.1997352], [-15.5013261, 33.0666986]]
end

imagery_layer "zw_topo_50k" do
  site "zimbabwe-topo.openstreetmap.org.za"
  title "Zimbabwe Topo 50k"
  projection "EPSG:3857"
  source "/store/imagery/zw/50k-topo/combined.webp.google.r_lanczos.bs_256.aligned.cog.tif"
  copyright "Surveyor-General, Zimbabwe"
  default_layer true
  revision 2
end
