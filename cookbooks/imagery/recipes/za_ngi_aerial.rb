#
# Cookbook:: imagery
# Recipe:: za_ngi_aerial
#
# Copyright:: 2024, OpenStreetMap Foundation
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

include_recipe "imagery::tiler"

imagery_site "aerial.openstreetmap.org.za" do
  title "OpenStreetMap - NGI - Aerial Imagery"
  aliases ["aerial.osm.org.za"]
  bbox [[-35.12, 16.23], [-22.1, 33.18]]
  uses_tiler true
end

imagery_layer "ngi-aerial" do
  site "aerial.openstreetmap.org.za"
  uses_tiler true
  title "NGI Aerial 25cm/50cm"
  source "file:///store/imagery/za/za-25cm/mosaic-tiler-file.json"
  copyright 'State Copyright &copy; 2024 <a href="https://ngi.dalrrd.gov.za/">Chief Directorate: National Geo-spatial Information</a>'
  max_zoom 20
  extension "jpg"
  default_layer true
  url_aliases ["/ngi-aerial"]
end
