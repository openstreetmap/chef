#
# Cookbook:: imagery
# Recipe:: gb_os_sv
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

cookbook_file "/srv/imagery/common/ossv-palette.txt" do
  source "ossv-palette.txt"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/srv/imagery/common/os-openmap-local-palette.txt" do
  source "os-openmap-local-palette.txt"
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

cookbook_file "/srv/imagery/common/osstvw_make_diffs" do
  source "osstvw_make_diffs"
  owner "root"
  group "root"
  mode "0755"
end

imagery_site "os.openstreetmap.org" do
  title "OpenStreetMap - Ordnance Survey OpenData - Street View"
  aliases ["os.osm.org", "os.openstreetmap.org.uk"]
  bbox [[49.85, -10.5], [58.75, 1.9]]
end

imagery_layer "gb_os_sv_2010_04" do
  site "os.openstreetmap.org"
  title "April 2010"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2010-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2010" # FIXME: Correct Copyright?
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2010-04"]
end

imagery_layer "gb_os_sv_2010_11" do
  site "os.openstreetmap.org"
  title "November 2010"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2010-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2010" # FIXME: Correct Copyright?
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2010-11"]
end

imagery_layer "gb_os_sv_2011_05" do
  site "os.openstreetmap.org"
  title "May 2011"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2011-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2011" # FIXME: Correct Copyright?
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2011-05"]
end

imagery_layer "gb_os_sv_2011_11" do
  site "os.openstreetmap.org"
  title "November 2011"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2011-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2011" # FIXME: Correct Copyright?
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2011-11"]
end

imagery_layer "gb_os_sv_2012_05" do
  site "os.openstreetmap.org"
  title "May 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2012-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2012-05"]
end

imagery_layer "gb_os_sv_2012_11" do
  site "os.openstreetmap.org"
  title "November 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2012-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2012-11"]
end

imagery_layer "gb_os_sv_2013_05" do
  site "os.openstreetmap.org"
  title "May 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2013-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2013-05"]
end

imagery_layer "gb_os_sv_2013_11" do
  site "os.openstreetmap.org"
  title "November 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2013-11"]
end

imagery_layer "gb_os_sv_2014_04" do
  site "os.openstreetmap.org"
  title "April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2014-04"]
end

imagery_layer "gb_os_sv_2014_10" do
  site "os.openstreetmap.org"
  title "October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2014-10"]
end

imagery_layer "gb_os_sv_2015_05" do
  site "os.openstreetmap.org"
  title "May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2015-05"]
end

imagery_layer "gb_os_sv_2015_11" do
  site "os.openstreetmap.org"
  title "November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2015-11"]
end

imagery_layer "gb_os_sv_2016_04" do
  site "os.openstreetmap.org"
  title "April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  background_colour "230 246 255" # OSSV Water Blue
  extension "os_sv_png"
  url_aliases ["/sv-2016-04", "/sv"] # Add "/sv" to current edition for backward compatibility
end

# ======= Diff layers =======

imagery_layer "gb_os_sv_diff_2010_04_2010_11" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to November 2010"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2010-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2010"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2010-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2011_05" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to May 2011"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2011-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2011"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2011-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2011_11" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to November 2011"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2011-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2011"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2011-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2012_05" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to May 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2012-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2012-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2012_11" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to November 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2012-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2012-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2013_05" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to May 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2013-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2013-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2013_11" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to November 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2013-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2014_04" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2014-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2014_10" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2015_05" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2015_11" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_04_2016_04" do
  site "os.openstreetmap.org"
  title "Changes April 2010 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-04-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-04-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2011_05" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to May 2011"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2011-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2011"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2011-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2011_11" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to November 2011"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2011-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2011"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2011-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2012_05" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to May 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2012-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2012-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2012_11" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to November 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2012-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2012-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2013_05" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to May 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2013-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2013-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2013_11" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to November 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2013-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2014_04" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2014-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2014_10" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2015_05" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2015_11" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2010_11_2016_04" do
  site "os.openstreetmap.org"
  title "Changes November 2010 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2010-11-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2010-11-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2011_11" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to November 2011"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2011-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2011"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2011-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2012_05" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to May 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2012-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2012-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2012_11" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to November 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2012-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2012-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2013_05" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to May 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2013-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2013-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2013_11" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to November 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2013-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2014_04" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2014-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2014_10" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2015_05" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2015_11" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_05_2016_04" do
  site "os.openstreetmap.org"
  title "Changes May 2011 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-05-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-05-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2012_05" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to May 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2012-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2012-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2012_11" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to November 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2012-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2012-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2013_05" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to May 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2013-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2013-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2013_11" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to November 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2013-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2014_04" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2014-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2014_10" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2011"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2015_05" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2015_11" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2011_11_2016_04" do
  site "os.openstreetmap.org"
  title "Changes November 2011 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2011-11-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2011-11-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_05_2012_11" do
  site "os.openstreetmap.org"
  title "Changes May 2012 to November 2012"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-05-2012-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2012"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-05-2012-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_05_2013_05" do
  site "os.openstreetmap.org"
  title "Changes May 2012 to May 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-05-2013-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-05-2013-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_05_2013_11" do
  site "os.openstreetmap.org"
  title "Changes May 2012 to November 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-05-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-05-2013-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_05_2014_04" do
  site "os.openstreetmap.org"
  title "Changes May 2012 to April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-05-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-05-2014-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_05_2014_10" do
  site "os.openstreetmap.org"
  title "Changes May 2012 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-05-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-05-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_05_2015_05" do
  site "os.openstreetmap.org"
  title "Changes May 2012 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-05-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-05-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_05_2015_11" do
  site "os.openstreetmap.org"
  title "Changes May 2012 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-05-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-05-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_05_2016_04" do
  site "os.openstreetmap.org"
  title "Changes May 2012 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-05-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-05-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_11_2013_05" do
  site "os.openstreetmap.org"
  title "Changes November 2012 to May 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-11-2013-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-11-2013-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_11_2013_11" do
  site "os.openstreetmap.org"
  title "Changes November 2012 to November 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-11-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-11-2013-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_11_2014_04" do
  site "os.openstreetmap.org"
  title "Changes November 2012 to April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-11-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-11-2014-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_11_2014_10" do
  site "os.openstreetmap.org"
  title "Changes November 2012 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-11-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-11-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_11_2015_05" do
  site "os.openstreetmap.org"
  title "Changes November 2012 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-11-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-11-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_11_2015_11" do
  site "os.openstreetmap.org"
  title "Changes November 2012 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-11-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-11-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2012_11_2016_04" do
  site "os.openstreetmap.org"
  title "Changes November 2012 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2012-11-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2012-11-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_05_2013_11" do
  site "os.openstreetmap.org"
  title "Changes May 2013 to November 2013"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-05-2013-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2013"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-05-2013-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_05_2014_04" do
  site "os.openstreetmap.org"
  title "Changes May 2013 to April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-05-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-05-2014-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_05_2014_10" do
  site "os.openstreetmap.org"
  title "Changes May 2013 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-05-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-05-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_05_2015_05" do
  site "os.openstreetmap.org"
  title "Changes May 2013 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-05-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-05-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_05_2015_11" do
  site "os.openstreetmap.org"
  title "Changes May 2013 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-05-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-05-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_05_2016_04" do
  site "os.openstreetmap.org"
  title "Changes May 2013 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-05-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-05-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_11_2014_04" do
  site "os.openstreetmap.org"
  title "Changes November 2013 to April 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-11-2014-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-11-2014-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_11_2014_10" do
  site "os.openstreetmap.org"
  title "Changes November 2013 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-11-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-11-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_11_2015_05" do
  site "os.openstreetmap.org"
  title "Changes November 2013 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-11-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-11-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_11_2015_11" do
  site "os.openstreetmap.org"
  title "Changes November 2013 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-11-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-11-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2013_11_2016_04" do
  site "os.openstreetmap.org"
  title "Changes November 2013 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2013-11-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2013-11-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2014_04_2014_10" do
  site "os.openstreetmap.org"
  title "Changes April 2014 to October 2014"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2014-04-2014-10-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2014"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2014-04-2014-10"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2014_04_2015_05" do
  site "os.openstreetmap.org"
  title "Changes April 2014 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2014-04-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2014-04-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2014_04_2015_11" do
  site "os.openstreetmap.org"
  title "Changes April 2014 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2014-04-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2014-04-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2014_04_2016_04" do
  site "os.openstreetmap.org"
  title "Changes April 2014 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2014-04-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2014-04-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2014_10_2015_05" do
  site "os.openstreetmap.org"
  title "Changes October 2014 to May 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2014-10-2015-05-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2014-10-2015-05"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2014_10_2015_11" do
  site "os.openstreetmap.org"
  title "Changes October 2014 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2014-10-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2014-10-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2014_10_2016_04" do
  site "os.openstreetmap.org"
  title "Changes October 2014 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2014-10-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2014-10-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2015_05_2015_11" do
  site "os.openstreetmap.org"
  title "Changes May 2015 to November 2015"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2015-05-2015-11-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2015"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2015-05-2015-11"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2015_05_2016_04" do
  site "os.openstreetmap.org"
  title "Changes May 2015 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2015-05-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2015-05-2016-04"]
  overlay true
end

imagery_layer "gb_os_sv_diff_2015_11_2016_04" do
  site "os.openstreetmap.org"
  title "Changes November 2015 to April 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/os-sv/ossv-diff-2015-11-2016-04-combined.vrt"
  copyright "Contains Ordnance Survey data &copy; Crown copyright and database right 2016"
  extension "os_sv_diff_png"
  url_aliases ["/sv-diff-2015-11-2016-04"]
  overlay true
end

imagery_layer "gb_os_om_local_2020_04" do
  site "os.openstreetmap.org"
  title "OS OpenMap Local - April 2020"
  projection "EPSG:27700"
  source "/data/imagery/gb/openmap-local/2020-04/os-openmap-local-2020-04-combined-sea-average-zstd22.vrt"
  copyright "Contains OS data &copy; Crown copyright and database right 2020"
  revision 2
  background_colour "213 244 248" # OS OpenMap Local Water Blue
  extension "os_om_local_png"
  url_aliases ["/om-local-2020-04", "/om-local"]
  default_layer true
end

imagery_layer "gb_os_om_local_2016_10" do
  site "os.openstreetmap.org"
  title "OS OpenMap Local - October 2016"
  projection "EPSG:27700"
  source "/data/imagery/gb/openmap-local/2016-10/os-openmap-local-2016-10.vrt"
  copyright "Contains OS data &copy; Crown copyright and database right 2016"
  background_colour "213 244 248" # OS OpenMap Local Water Blue
  extension "os_om_local_png"
end

imagery_layer "gb_os_om_local_2017_04" do
  site "os.openstreetmap.org"
  title "OS OpenMap Local - April 2017"
  projection "EPSG:27700"
  source "/data/imagery/gb/openmap-local/2017-04/os-openmap-local-2017-04.vrt"
  copyright "Contains OS data &copy; Crown copyright and database right 2017"
  background_colour "213 244 248" # OS OpenMap Local Water Blue
  extension "os_om_local_png"
end

imagery_layer "gb_os_om_local_2017_10" do
  site "os.openstreetmap.org"
  title "OS OpenMap Local - October 2017"
  projection "EPSG:27700"
  source "/data/imagery/gb/openmap-local/2017-10/os-openmap-local-2017-10.vrt"
  copyright "Contains OS data &copy; Crown copyright and database right 2017"
  background_colour "213 244 248" # OS OpenMap Local Water Blue
  extension "os_om_local_png"
end

imagery_layer "gb_os_om_local_2018_04" do
  site "os.openstreetmap.org"
  title "OS OpenMap Local - April 2018"
  projection "EPSG:27700"
  source "/data/imagery/gb/openmap-local/2018-04/os-openmap-local-2018-04.vrt"
  copyright "Contains OS data &copy; Crown copyright and database right 2018"
  background_colour "213 244 248" # OS OpenMap Local Water Blue
  extension "os_om_local_png"
end

imagery_layer "gb_os_om_local_2018_05" do
  site "os.openstreetmap.org"
  title "OS OpenMap Local - May 2018"
  projection "EPSG:27700"
  source "/data/imagery/gb/openmap-local/2018-05/os-openmap-local-2018-05.vrt"
  copyright "Contains OS data &copy; Crown copyright and database right 2018"
  background_colour "213 244 248" # OS OpenMap Local Water Blue
  extension "os_om_local_png"
end

imagery_layer "gb_os_om_local_2019_04" do
  site "os.openstreetmap.org"
  title "OS OpenMap Local - April 2019"
  projection "EPSG:27700"
  source "/data/imagery/gb/openmap-local/2019-04/os-openmap-local-2019-04.vrt"
  copyright "Contains OS data &copy; Crown copyright and database right 2019"
  background_colour "213 244 248" # OS OpenMap Local Water Blue
  extension "os_om_local_png"
end
