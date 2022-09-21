#
# Cookbook:: stateofthemap
# Recipe:: jekyll
#
# Copyright:: 2022, OpenStreetMap Foundation
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

include_recipe "stateofthemap"
include_recipe "ruby"

package %w[
  gcc
  g++
  make
  libssl-dev
  zlib1g-dev
  pkg-config
]

apache_module "expires"
apache_module "rewrite"

%w[2016 2017 2018 2019 2020 2021 2022].each do |year|
  git "/srv/#{year}.stateofthemap.org" do
    action :sync
    repository "https://github.com/openstreetmap/stateofthemap-#{year}.git"
    depth 1
    user "root"
    group "root"
    notifies :extract, "archive_file[/srv/#{year}.stateofthemap.org/vendor/bundle-tar-cache]", :immediately
    notifies :run, "bundle_install[/srv/#{year}.stateofthemap.org]", :immediately
  end

  directory "/srv/#{year}.stateofthemap.org/_site" do
    mode "755"
    owner "nobody"
    group "nogroup"
  end

  # Workaround https://github.com/jekyll/jekyll/issues/7804
  # by creating a .jekyll-cache folder
  directory "/srv/#{year}.stateofthemap.org/.jekyll-cache" do
    mode "755"
    owner "nobody"
    group "nogroup"
  end

  archive_file "/srv/#{year}.stateofthemap.org/vendor/bundle-tar-cache" do
    action :nothing
    destination "/srv/#{year}.stateofthemap.org/vendor"
    path "#{Chef::Config[:file_cache_path]}/stateofthemap-gem-bundle-cache.tar"
    overwrite false
    only_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/stateofthemap-gem-bundle-cache.tar") }
    not_if { ::Dir.exist?("/srv/#{year}.stateofthemap.org/vendor/bundle") }
    only_if { kitchen? }
  end

  bundle_install "/srv/#{year}.stateofthemap.org" do
    action :nothing
    options "--deployment --jobs #{node[:cpu][:total]}"
    user "root"
    group "root"
    notifies :run, "execute[/srv/#{year}.stateofthemap.org/vendor/bundle-tar-cache]", :immediately
    notifies :run, "bundle_exec[/srv/#{year}.stateofthemap.org]"
    only_if { ::File.exist?("/srv/#{year}.stateofthemap.org/Gemfile") }
  end

  execute "/srv/#{year}.stateofthemap.org/vendor/bundle-tar-cache" do
    action :nothing
    command "tar -cf #{Chef::Config[:file_cache_path]}/stateofthemap-gem-bundle-cache.tar bundle"
    cwd "/srv/#{year}.stateofthemap.org/vendor"
    not_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/stateofthemap-gem-bundle-cache.tar") }
    only_if { ::Dir.exist?("/srv/#{year}.stateofthemap.org/vendor/bundle") }
    only_if { kitchen? }
  end

  bundle_exec "/srv/#{year}.stateofthemap.org" do
    action :nothing
    command "jekyll build --trace --baseurl=https://#{year}.stateofthemap.org"
    user "nobody"
    group "nogroup"
    environment "LANG" => "C.UTF-8"
  end

  ssl_certificate "#{year}.stateofthemap.org" do
    domains ["#{year}.stateofthemap.org", "#{year}.stateofthemap.com", "#{year}.sotm.org"]
    notifies :reload, "service[apache2]"
  end

  apache_site "#{year}.stateofthemap.org" do
    template "apache.jekyll.erb"
    directory "/srv/#{year}.stateofthemap.org/_site"
    variables :year => year
  end
end
