#
# Cookbook Name:: imagery
# Recipe:: gb_os_sv
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

cookbook_file "/srv/imagery/common/ossv-palette.txt" do
  source "ossv-palette.txt"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/srv/imagery/common/osstvw_process" do
  source "osstvw_process"
  owner "root"
  group "root"
  mode "0755"
end

imagery_site "os.openstreetmap.org" do
  aliases ["os.openstreetmap.org.uk"]
end

imagery_layer "gb_os_sv_2010_04" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2010-04-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2010" # FIXME: Correct Copyright?
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2010-04"]
end

imagery_layer "gb_os_sv_2010_11" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2010-11-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2010" # FIXME: Correct Copyright?
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2010-11"]
end

imagery_layer "gb_os_sv_2011_05" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2011-05-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2011" # FIXME: Correct Copyright?
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2011-05"]
end

imagery_layer "gb_os_sv_2011_11" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2011-11-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2011" # FIXME: Correct Copyright?
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2011-11"]
end

imagery_layer "gb_os_sv_2012_05" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2012-05-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2012"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2012-05"]
end

imagery_layer "gb_os_sv_2012_11" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2012-11-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2012"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2012-11"]
end

imagery_layer "gb_os_sv_2013_05" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2013-05-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2013"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2013-05"]
end

imagery_layer "gb_os_sv_2013_11" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2013"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2013-11"]
end

imagery_layer "gb_os_sv_2014_04" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2014"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2014-04"]
end

imagery_layer "gb_os_sv_2014_10" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2014"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2014-10"]
end

imagery_layer "gb_os_sv_2015_05" do
  site "os.openstreetmap.org"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2015"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2015-05"]
end

imagery_layer "gb_os_sv_2015_11" do
  site "os.openstreetmap.org"
  root_layer true
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2015"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2015-11"]
end

imagery_layer "gb_os_sv_2016_04" do
  site "os.openstreetmap.org"
  root_layer true
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data © Crown copyright and database right 2016"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2016-04", "/sv"] # Add "/sv" to current edition for backward compatibility
end
