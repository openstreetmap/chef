#
# Cookbook:: taginfo
# Recipe:: default
#
# Copyright:: 2014, OpenStreetMap Foundation
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

require "json"

include_recipe "accounts"
include_recipe "apache"
include_recipe "git"
include_recipe "passenger"
include_recipe "planet::current"
include_recipe "prometheus"
include_recipe "ruby"

package %w[
  libsqlite3-dev
  zlib1g-dev
  libbz2-dev
  libboost-dev
  libexpat1-dev
  libsparsehash-dev
  libgd-dev
  libicu-dev
  libboost-program-options-dev
  libosmium2-dev
  libprotozero-dev
  cmake
  make
  g++
]

package %w[
  sqlite3
  sqlite3-pcre
  osmium-tool
  pyosmium
  curl
  pbzip2
]

apache_module "cache"
apache_module "cache_disk"
apache_module "headers"

directory "/var/log/taginfo" do
  owner "taginfo"
  group "taginfo"
  mode "755"
end

template "/etc/sudoers.d/taginfo" do
  source "sudoers.erb"
  owner "root"
  group "root"
  mode "440"
end

systemd_service "taginfo-update@" do
  description "Taginfo update for %i"
  wants "planet-update.service"
  after "planet-update.service"
  exec_start "/srv/%i/bin/update"
  user "taginfo"
  sandbox :enable_network => true
  restrict_address_families "AF_UNIX"
  read_write_paths [
    "/srv/%i/data",
    "/srv/%i/download",
    "/srv/%i/sources",
    "/var/log/taginfo/%i"
  ]
end

systemd_timer "taginfo-update@" do
  description "Taginfo update for %i"
  on_calendar "01:37"
end

node[:taginfo][:sites].each do |site|
  site_name = site[:name]
  site_aliases = Array(site[:aliases])
  directory = site[:directory] || "/srv/#{site_name}"
  description = site[:description]
  about = site[:about]
  icon = site[:icon]
  contact = site[:contact]

  directory "/var/log/taginfo/#{site_name}" do
    owner "taginfo"
    group "taginfo"
    mode "755"
  end

  directory directory do
    owner "taginfo"
    group "taginfo"
    mode "755"
  end

  git "#{directory}/taginfo-tools" do
    action :sync
    repository "https://github.com/taginfo/taginfo-tools.git"
    revision "osmorg-taginfo-live"
    depth 1
    enable_submodules true
    user "taginfo"
    group "taginfo"
  end

  directory "#{directory}/build" do
    owner "taginfo"
    group "taginfo"
    mode "755"
  end

  execute "compile_taginfo_tools" do
    action :nothing
    user "taginfo"
    group "taginfo"
    cwd "#{directory}/build"
    command "cmake #{directory}/taginfo-tools -DCMAKE_BUILD_TYPE=Release && make"
    subscribes :run, "apt_package[libprotozero-dev]"
    subscribes :run, "apt_package[libosmium2-dev]"
    subscribes :run, "git[#{directory}/taginfo-tools]"
  end

  git "#{directory}/taginfo" do
    action :sync
    repository "https://github.com/taginfo/taginfo.git"
    revision "osmorg-taginfo-live"
    depth 1
    user "taginfo"
    group "taginfo"
  end

  settings = Chef::DelayedEvaluator.new do
    settings = JSON.parse(IO.read("#{directory}/taginfo/taginfo-config-example.json"))

    settings["instance"]["url"] = "https://#{site_name}/"
    settings["instance"]["description"] = description
    settings["instance"]["about"] = about
    settings["instance"]["icon"] = "/img/logo/#{icon}.png"
    settings["instance"]["contact"] = contact
    settings["instance"]["access_control_allow_origin"] = ""
    settings["logging"]["directory"] = "/var/log/taginfo/#{site_name}"
    settings["opensearch"]["shortname"] = "Taginfo"
    settings["opensearch"]["contact"] = "webmaster@openstreetmap.org"
    settings["paths"]["bin_dir"] = "#{directory}/build/src"
    settings["sources"]["download"] = ""
    settings["sources"]["create"] = "db languages projects wiki wikidata chronology"
    settings["sources"]["db"]["planetfile"] = "/var/lib/planet/planet.osh.pbf"
    settings["sources"]["chronology"]["osm_history_file"] = "/var/lib/planet/planet.osh.pbf"
    settings["tagstats"]["geodistribution"] = "DenseMmapArray"

    JSON.pretty_generate(settings)
  end

  file "#{directory}/taginfo-config.json" do
    owner "taginfo"
    group "taginfo"
    mode "644"
    content settings
    notifies :restart, "service[apache2]"
  end

  bundle_install "#{directory}/taginfo" do
    action :nothing
    user "root"
    group "root"
    subscribes :run, "git[#{directory}/taginfo]"
    notifies :restart, "passenger_application[#{directory}/taginfo/web/public]"
  end

  %w[taginfo/web/tmp bin data data/old download sources].each do |dir|
    directory "#{directory}/#{dir}" do
      owner "taginfo"
      group "taginfo"
      mode "755"
    end
  end

  template "#{directory}/bin/update" do
    source "update.erb"
    owner "taginfo"
    group "taginfo"
    mode "755"
    variables :name => site_name, :directory => directory
  end

  passenger_application "#{directory}/taginfo/web/public" do
    action :nothing
  end

  ssl_certificate site_name do
    domains [site_name] + site_aliases
    notifies :reload, "service[apache2]"
  end

  apache_site site_name do
    template "apache.erb"
    directory "#{directory}/taginfo/web/public"
    variables :aliases => site_aliases
  end

  service "taginfo-update@#{site_name}.timer" do
    action [:enable, :start]
  end

  prometheus_collector "taginfo-#{site_name}" do
    interval "15m"
    user "taginfo"
    path "#{directory}/taginfo/sources/metrics.rb"
    options "#{directory}/data"
  end
end
