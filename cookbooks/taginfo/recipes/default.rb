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
package "libbz2-dev"
package "libboost-dev"
package "libexpat1-dev"
package "libsparsehash-dev"
package "libgd2-xpm-dev"
package "libicu-dev"
package "libboost-program-options-dev"
package "cmake"
package "make"
package "g++"

package "sqlite3"
package "osmosis"
package "curl"
package "m4"

package "ruby#{node[:passenger][:ruby_version]}"
package "rubygems#{node[:passenger][:ruby_version]}"
gem_package "json"
gem_package "sqlite3"
gem_package "sinatra"
gem_package "sinatra-r18n"
gem_package "rack-contrib"

apache_module "cache"
apache_module "cache_disk"
apache_module "headers"

template "/etc/cron.d/taginfo" do
  source "cron.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/var/log/taginfo" do
  owner "taginfo"
  group "taginfo"
  mode 0755
end

file "/etc/logrotate.d/taginfo" do
  action :delete
end

template "/etc/sudoers.d/taginfo" do
  source "sudoers.erb"
  owner "root"
  group "root"
  mode 0440
end

node[:taginfo][:sites].each do |site|
  name = site[:name]
  directory = site[:directory] || "/srv/#{name}"
  description = site[:description]
  about = site[:about]
  icon = site[:icon]
  contact = site[:contact]

  directory "/var/log/taginfo/#{name}" do
    owner "taginfo"
    group "taginfo"
    mode 0755
  end

  directory directory do
    owner "taginfo"
    group "taginfo"
    mode 0755
  end

  git "#{directory}/libosmium" do
    action :sync
    repository "git://github.com/osmcode/libosmium.git"
    revision "v2.5.3"
    user "taginfo"
    group "taginfo"
  end

  git "#{directory}/osmium-tool" do
    action :sync
    repository "git://github.com/osmcode/osmium-tool.git"
    revision "v1.3.0"
    user "taginfo"
    group "taginfo"
  end

  git "#{directory}/taginfo" do
    action :sync
    repository "git://github.com/joto/taginfo.git"
    revision "osmorg-taginfo-live"
    user "taginfo"
    group "taginfo"
  end

  settings = Chef::DelayedEvaluator.new do
    settings = JSON.parse(IO.read("#{directory}/taginfo/taginfo-config-example.json"))

    settings["instance"]["url"] = "http://#{name}/"
    settings["instance"]["description"] = description
    settings["instance"]["about"] = about
    settings["instance"]["icon"] = "/img/logo/#{icon}.png"
    settings["instance"]["contact"] = contact
    settings["instance"]["access_control_allow_origin"] = ""
    settings["logging"]["directory"] = "/var/log/taginfo/#{name}"
    settings["opensearch"]["shortname"] = "Taginfo"
    settings["opensearch"]["contact"] = "webmaster@openstreetmap.org"
    settings["sources"]["download"] = ""
    settings["sources"]["create"] = "db languages projects wiki"
    settings["sources"]["db"]["planetfile"] = "#{directory}/planet/planet.pbf"
    settings["sources"]["db"]["bindir"] = "#{directory}/taginfo/tagstats"
    settings["sources"]["db"]["tagstats"] = "#{directory}/taginfo/tagstats/tagstats"
    settings["tagstats"]["cxxflags"] = "-I../../libosmium/include"
    settings["tagstats"]["geodistribution"] = "DenseMmapArray"
    settings["user_interface"]["key_page"]["show_tab_similar"] = true
    settings["level0"]["overpass_url_prefix"] = "http://overpass-api.de/api/interpreter?"

    JSON.pretty_generate(settings)
  end

  file "#{directory}/taginfo-config.json" do
    owner "taginfo"
    group "taginfo"
    mode 0644
    content settings
    notifies :restart, "service[apache2]"
  end

  execute "#{directory}/taginfo/tagstats/Makefile" do
    action :nothing
    command "make"
    cwd "#{directory}/taginfo/tagstats"
    user "taginfo"
    group "taginfo"
    subscribes :run, "git[#{directory}/libosmium]"
    subscribes :run, "git[#{directory}/taginfo]"
    notifies :restart, "service[apache2]"
  end

  directory "#{directory}/osmium-tool/build" do
    owner "taginfo"
    group "taginfo"
    mode "0755"
    action :create
    subscribes :create, "git[#{directory}/libosmium]"
    subscribes :create, "git[#{directory}/osmium-tool]"
  end

  execute "compile-osmium" do
    action :nothing
    command "cmake .. && make"
    cwd "#{directory}/osmium-tool/build"
    user "taginfo"
    group "taginfo"
    subscribes :run, "git[#{directory}/libosmium]"
    subscribes :run, "git[#{directory}/osmium-tool]"
    subscribes :run, "directory[#{directory}/osmium-tool/build]"
  end

  %w(taginfo/web/tmp bin data data/old download sources planet planet/log planet/replication).each do |dir|
    directory "#{directory}/#{dir}" do
      owner "taginfo"
      group "taginfo"
      mode 0755
    end
  end

  remote_file "#{directory}/planet/planet.pbf" do
    action :create_if_missing
    source "http://planet.openstreetmap.org/pbf/planet-latest.osm.pbf"
    owner "taginfo"
    group "taginfo"
    mode 0644
  end

  template "#{directory}/planet/replication/configuration.txt" do
    source "configuration.txt.erb"
    owner "taginfo"
    group "taginfo"
    mode 0644
  end

  file "#{directory}/planet/replication/download.lock" do
    owner "taginfo"
    group "taginfo"
    mode 0644
  end

  template "#{directory}/bin/update-planet" do
    source "update-planet.erb"
    owner "taginfo"
    group "taginfo"
    mode 0755
    variables :directory => directory
  end

  template "#{directory}/bin/update-taginfo" do
    source "update-taginfo.erb"
    owner "taginfo"
    group "taginfo"
    mode 0755
    variables :directory => directory
  end

  template "#{directory}/bin/update" do
    source "update.erb"
    owner "taginfo"
    group "taginfo"
    mode 0755
    variables :name => name, :directory => directory
  end

  apache_site name do
    template "apache.erb"
    directory "#{directory}/taginfo/web/public"
  end
end
