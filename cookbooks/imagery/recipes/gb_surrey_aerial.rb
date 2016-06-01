#
# Cookbook Name:: imagery
# Recipe:: gb_surrey_aerial
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

imagery_site "surrey.aerial.openstreetmap.org.uk" do
  title "OpenStreetMap - Surrey Air Survey - 2009"
  bbox [[51.06686, -0.85762], [51.47753, 0.06592]]
end

imagery_layer "gb_surrey_aerial" do
  site "surrey.aerial.openstreetmap.org.uk"
  root_layer true
  default_layer true
  projection "EPSG:27700"
  source "/data/imagery/gb/surrey-aerial/SurreyMosaicECW.tif"
  title "Surrey Air Survey - 2008/2009"
  copyright "ODC Open Database License (ODbL) - Surrey Heath Borough Council"
  url_aliases ["/sas"]
end
