#
# Cookbook:: imagery
# Recipe:: gb_ea
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

imagery_site "ea.openstreetmap.org.uk" do
  title "OpenStreetMap - Environment Agency OpenData"
  bbox [[51.35, -2.2], [52.65, 0.10]]
end

imagery_layer "gb_ea_night" do
  site "ea.openstreetmap.org.uk"
  title "Environment Agency - Night Time Aerial"
  default_layer true
  projection "EPSG:27700"
  source "/data/imagery/gb/ea/night/ea-night-test.vrt"
  max_zoom 20
  copyright "&copy; Environment Agency copyright and/or database right 2016. All rights reserved."
  background_colour "0 0 0"
end

imagery_layer "gb_ea_ortho_2015" do
  site "ea.openstreetmap.org.uk"
  title "Environment Agency - Ortho - 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/ea/ortho/ea-ortho-2015-combined.vrt"
  max_zoom 20
  copyright "&copy; Environment Agency copyright and/or database right 2016. All rights reserved."
  background_colour "0 0 0"
end
