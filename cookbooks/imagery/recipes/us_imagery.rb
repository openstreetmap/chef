#
# Cookbook:: imagery
# Recipe:: us_imagery
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

imagery_site "us-imagery.openstreetmap.org" do
  title "OpenStreetMap - USA - Aerial Imagery"
  aliases ["us-imagery.osm.org"]
  bbox [[29.62360872200975, -98.9703369140625], [31.048227924549767, -96.56089782714842]]
  uses_tiler true
end

imagery_layer "capcog-2022" do
  site "us-imagery.openstreetmap.org"
  uses_tiler true
  title "US CAPCOG 2022"
  source "file:///store/imagery/us/capcog-2022-nc-cir-12in/tiles/mosaic-tiler-file.json"
  copyright "(c) 2022 CAPCOG"
  max_zoom 20
  extension "jpg"
  default_layer true
end
