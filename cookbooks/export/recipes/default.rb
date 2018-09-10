#
# Cookbook Name:: export
# Recipe:: default
#
# Copyright 2018, OpenStreetMap Foundation
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

include_recipe "cplanet"
include_recipe "git"

package %w[
  bc
  cimg-dev
  cmake
  g++
  gdal-bin
  libboost-dev
  libboost-program-options-dev
  libbz2-dev
  libexpat1-dev
  libgdal-dev
  libgeos-dev
  libosmium2-dev
  libproj-dev
  libprotozero-dev
  libsqlite3-dev
  make
  osmium-tool
  proj-data
  python-gdal
  spatialite-bin
  sqlite3
  zip
  zlib1g-dev
]

basedir = "/srv/export"
cplanetdir = "/srv/cplanet"

directory basedir do
  owner "root"
  group "root"
  mode 0o755
end

directory "#{basedir}/bin" do
  owner "root"
  group "root"
  mode 0o755
end

directory "#{basedir}/software" do
  owner "export"
  group "export"
  mode 0o755
end

git "#{basedir}/software/gdal-tools" do
  action :sync
  repository "https://github.com/imagico/gdal-tools.git"
  revision "9c86fefe259ab5265d17169e090f377c9ee6a448"
  user "export"
  group "export"
end

git "#{basedir}/software/icesheet_proc" do
  action :sync
  repository "https://github.com/imagico/icesheet_proc"
  revision "be4400fadac9488f19b8831ed1ef530a16912ef4"
  user "export"
  group "export"
end

git "#{basedir}/software/osmcoastline" do
  action :sync
  repository "git://github.com/osmcode/osmcoastline.git"
  revision "v2.2.0"
  user "export"
  group "export"
end

git "#{basedir}/software/polysplit" do
  action :sync
  repository "https://github.com/joto/polysplit"
  revision "db7f639217f8b7cd81938a1003f84540c3afcc42"
  user "export"
  group "export"
end

directory "#{basedir}/software/osmcoastline/build" do
  owner "export"
  group "export"
  mode 0o755
end

execute "compile-gdal-tools" do
  action :nothing
  command "make gdal_maskcompare_wm"
  cwd "#{basedir}/software/gdal-tools"
  user "export"
  group "export"
  subscribes :run, "git[#{basedir}/software/gdal-tools]"
end

execute "compile-icesheet-proc" do
  action :nothing
  command "make"
  cwd "#{basedir}/software/icesheet_proc"
  user "export"
  group "export"
  subscribes :run, "git[#{basedir}/software/icesheet_proc]"
end

execute "compile-osmcoastline" do
  action :nothing
  command "cmake .. && make"
  cwd "#{basedir}/software/osmcoastline/build"
  user "export"
  group "export"
  subscribes :run, "git[#{basedir}/software/osmcoastline]"
  subscribes :run, "directory[#{basedir}/software/osmcoastline/build]"
end

execute "compile-polysplit" do
  action :nothing
  command "make"
  cwd "#{basedir}/software/polysplit"
  user "export"
  group "export"
  subscribes :run, "git[#{basedir}/software/polysplit]"
end

%w[
    gdal-tools/gdal_maskcompare_wm
    icesheet_proc/osmium_noice
    icesheet_proc/icesheet_proc.sh
    osmcoastline/build/src/osmcoastline
    osmcoastline/build/src/osmcoastline_filter
    osmcoastline/build/src/osmcoastline_ways
    polysplit/polysplit
].each do |name|
  link "#{basedir}/bin/#{name.split('/')[-1]}" do
    to "../software/#{name}"
    link_type :symbolic
    owner "root"
    group "root"
  end
end

%w[data img log].each do |dir|
  directory "#{basedir}/#{dir}" do
    owner "export"
    group "export"
    mode 0o755
  end
end

%w[compare-coastline-polygons poly-grid README.tmpl update update-coastline update-icesheet].each do |fname|
  template "#{basedir}/bin/#{fname}" do
    source "#{fname}.erb"
    owner "root"
    group "root"
    mode 0o755
    variables :datadir => "#{basedir}/data",
              :logdir  => "#{basedir}/log",
              :imgdir  => "#{basedir}/img",
              :sqldir  => "#{basedir}/software/osmcoastline/simplify_and_split_spatialite",
              :planet  => "#{cplanetdir}/planet/planet.pbf"
  end
end

