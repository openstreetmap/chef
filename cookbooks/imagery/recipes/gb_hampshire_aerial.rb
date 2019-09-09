#
# Cookbook:: imagery
# Recipe:: gb_hampshire_aerial
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

imagery_site "hampshire.aerial.openstreetmap.org.uk" do
  title "OpenStreetMap - Hampshire Hub Aerial"
  bbox [[50.68993, -1.97823], [51.39492, -0.70724]]
end

imagery_layer "gb_hampshire_aerial_rgb" do
  site "hampshire.aerial.openstreetmap.org.uk"
  root_layer true
  default_layer true
  title "Hampshire Aerial - Summer 2013"
  source "/data/imagery/gb/hampshire-aerial/hampshire-aerial-RGB.tif"
  max_zoom 20
  projection "EPSG:27700"
  copyright "Hampshire Hub - Open Government Licence (OGL) 2014"
  url_aliases ["/hampshire-rgb"]
end

imagery_layer "gb_hampshire_aerial_fcir" do
  site "hampshire.aerial.openstreetmap.org.uk"
  title "Hampshire Aerial - Summer 2013 (False Colour IR)"
  source "/data/imagery/gb/hampshire-aerial/hampshire-aerial-FCIR.tif"
  max_zoom 20
  projection "EPSG:27700"
  copyright "Hampshire Hub - Open Government Licence (OGL) 2014"
  url_aliases ["/hampshire-fcir"]
end
