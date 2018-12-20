#
# Cookbook Name:: imagery
# Recipe:: za_ngi_topo
#
# Copyright 2016, OpenStreetMap Foundation
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

imagery_site "namibia-topo.openstreetmap.org.za" do
  title "OpenStreetMap - Namibia / South West Africa - Topographic Series"
  aliases ["namibia-topo.osm.org.za"]
  bbox [[-29.0003741, 11.7330477], [-16.9508650, 25.4983245]]
end

imagery_layer "na_sgswa_topo_50k" do
  site "namibia-topo.openstreetmap.org.za"
  title "Namibia Topo 50k"
  projection "EPSG:4326"
  source "/data/imagery/na/topo-50k/namibia-50k-topo.vrt"
  copyright "State Copyright &copy 1958 - 1991; Surveyor-General, Windhoek, SWA; CDSM: Chief Directorate Surveys & Mapping, Mowbray, RSA"
  default_layer true
  background_colour "0 0 0"
  extension "jpeg"
  default_layer true
  max_zoom 16
end
