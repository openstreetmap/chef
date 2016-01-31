#
# Cookbook Name:: imagery
# Recipe:: au-agri
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

imagery_site "agri.openstreetmap.org" do
  # aliases ["agri.openstreetmap.org.au"]

  imagery_layer "au_ga_agri" do
    site new_resource.name
    text "AGRI: The Australian Geographic Reference Image"
    copyright "Commonwealth of Australia (Geoscience Australia) - Creative Commons Attribution 4.0 International Licence"
    projection "EPSG:3857"
    source "/data/imagery/au/agri/combine.vrt"
  end
end
