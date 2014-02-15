#
# Cookbook Name:: taginfo
# Recipe:: default
#
# Copyright 2014, OpenStreetMap Foundation
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

require "json"

include_recipe "apache::ssl"
include_recipe "passenger"
include_recipe "git"

package "libsqlite3-dev"
package "zlib1g-dev"
package "libosmpbf-dev"
package "libprotobuf-dev"
package "libboost-dev"
package "libexpat1-dev"
package "libsparsehash-dev"
package "libgd2-xpm-dev"
package "make"
package "g++"

package "sqlite3"

package "ruby"
package "rubygems"
gem_package "json"
gem_package "sqlite3"
gem_package "sinatra"
gem_package "sinatra-r18n"
gem_package "rack-contrib"

node[:taginfo][:sites].each do |site|
  name = site[:name]
  directory = site[:directory] || "/srv/#{name}"
  description = site[:description]
  icon = site[:icon]
  contact = site[:contact]

  directory directory do
    owner "taginfo"
    group "taginfo"
    mode 0755
  end

  git "#{directory}/osmium" do
    action :sync
    repository "git://github.com/joto/osmium.git"
    revision "master"
    user "taginfo"
    group "taginfo"
  end

  git "#{directory}/taginfo" do
    action :sync
    repository "git://github.com/joto/taginfo.git"
    revision "master"
    user "taginfo"
    group "taginfo"
  end

  settings = JSON.parse(IO.read("#{directory}/taginfo/taginfo-config-example.json"))

  settings["instance"]["url"] = "http://#{name}/"
  settings["instance"]["description"] = description
  settings["instance"]["icon"] = "/img/logo/#{icon}.png"
  settings["instance"]["contact"] = contact
  settings["opensearch"]["shortname"] = "Taginfo"
  settings["opensearch"]["contact"] = "webmaster@openstreetmap.org"
  settings["tagstats"]["cxxflags"] = "-I../../osmium/include"

  file "#{directory}/taginfo-config.json" do
    owner "taginfo"
    group "taginfo"
    mode 0644
    content JSON.pretty_generate(settings)
  end

  execute "#{directory}/taginfo/tagstats/Makefile" do
    action :nothing
    command "make"
    cwd "#{directory}/taginfo/tagstats"
    user "taginfo"
    group "taginfo"
    subscribes :run, "git[#{directory}/osmium]"
    subscribes :run, "git[#{directory}/taginfo]"
    notifies :restart, "service[apache2]"
  end

  directory "#{directory}/planet" do
    owner "taginfo"
    group "taginfo"
    mode 0755
  end

  remote_file "#{directory}/planet/planet.pbf" do
    action :create_if_missing
    source "http://planet.openstreetmap.org/pbf/planet-latest.osm.pbf"
    owner "taginfo"
    group "taginfo"
    mode 0644
  end

  template "#{directory}/planet/configuration.txt" do
    source "configuration.txt.erb"
    owner "taginfo"
    group "taginfo"
    mode 0644
  end

  file "#{directory}/planet/download.lock" do
    owner "taginfo"
    group "taginfo"
    mode 0644
  end

  directory "#{directory}/bin" do
    owner "taginfo"
    group "taginfo"
    mode 0755
  end

  template "#{directory}/bin/update-planet" do
    source "update-planet.erb"
    owner "taginfo"
    group "taginfo"
    mode 0755
    variables :directory => directory
  end

  directory "#{directory}/data" do
    owner "taginfo"
    group "taginfo"
    mode 0755
  end

  apache_site name do
    template "apache.erb"
    directory "#{directory}/taginfo/web/public"
  end
end
