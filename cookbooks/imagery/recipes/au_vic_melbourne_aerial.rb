#
# Cookbook:: imagery
# Recipe:: au_vic_melbourne_aerial
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

include_recipe "imagery"

imagery_site "au-vic-melbourne-imagery.openstreetmap.org" do
  title "OpenStreetMap - City of Melbourne - Aerial Imagery"
  aliases ["au-vic-melbourne-imagery.osm.org"]
  # https://leafletjs.com/reference.html#latlngbounds format
  # [[south, west], [north, east]]
  bbox [[-37.850667, 144.896981], [-37.775451, 144.991351]]
end

imagery_layer "melbourne-2020" do
  site "au-vic-melbourne-imagery.openstreetmap.org"
  title "City of Melbourne 2020"
  source "/store/imagery/au/city-of-melbourne/CoM_May2020_2cm.cog.tiff"
  copyright "(c) 2020 City of Melbourne"
  max_zoom 23
  extension "jpg"
  default_layer true
end

imagery_layer "melbourne-2019" do
  site "au-vic-melbourne-imagery.openstreetmap.org"
  title "City of Melbourne 2019"
  source "/store/imagery/au/city-of-melbourne/CoM_03Feb2019.cog.tiff"
  copyright "(c) 2019 City of Melbourne"
  max_zoom 21
  extension "jpg"
end

imagery_layer "melbourne-2018" do
  site "au-vic-melbourne-imagery.openstreetmap.org"
  title "City of Melbourne 2018"
  source "/store/imagery/au/city-of-melbourne/CoM_May2018_10cm.COG.tiff"
  copyright "(c) 2018 City of Melbourne"
  max_zoom 21
  extension "jpg"
end
