#
# Cookbook:: imagery
# Recipe:: za_ngi_topo
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

imagery_site "topo.openstreetmap.org.za" do
  title "OpenStreetMap - NGI - Topographic Series"
  aliases ["topo.osm.org.za"]
  bbox [[-35.12, 16.23], [-22.1, 33.18]]
end

imagery_layer "za_ngi_topo_250k" do
  site "topo.openstreetmap.org.za"
  title "NGI Topo 250k"
  projection "EPSG:3857"
  source "/data/imagery/za/ngi-topo-250k/ngi-topo-250k-combined.vrt"
  copyright 'State Copyright &copy; 1996&ndash;2010 <a href="https://ngi.dalrrd.gov.za/">Chief Directorate: National Geo-spatial Information</a>'
  default_layer true
end

imagery_layer "za_ngi_topo_50k" do
  site "topo.openstreetmap.org.za"
  title "NGI Topo 50k"
  projection "EPSG:3857"
  source "/data/imagery/za/ngi-topo-50k/ngi-topo-50k-combined.vrt"
  copyright 'State Copyright &copy; 1996&ndash;2013 <a href="https://ngi.dalrrd.gov.za/">Chief Directorate: National Geo-spatial Information</a>'
end
