#
# Cookbook Name:: imagery
# Recipe:: gb-hampshire-aerial
#
# Copyright 2016, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "imagery"

imagery_site "hampshire.aerial.openstreetmap.org.uk" do
  # aliases
end

imagery_layer "gb_hampshire_aerial_rgb" do
  site "hampshire.aerial.openstreetmap.org.uk"
  text "Hampshire Aerial - Summer 2013"
  source "/data/imagery/gb/hampshire-aerial/hampshire-aerial-RGB.tif"
  projection "EPSG:27700"
  copyright "Hampshire Hub - Open Government Licence (OGL) 2014"
end

imagery_layer "gb_hampshire_aerial_fcir" do
  site "hampshire.aerial.openstreetmap.org.uk"
  text "Hampshire Aerial - Summer 2013 (FCIR)"
  source "/data/imagery/gb/hampshire-aerial/hampshire-aerial-FCIR.tif"
  projection "EPSG:27700"
  copyright "Hampshire Hub - Open Government Licence (OGL) 2014"
end
