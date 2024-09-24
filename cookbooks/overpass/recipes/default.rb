#
# Cookbook:: overpass
# Recipe:: default
#
# Copyright:: 2021, OpenStreetMap Foundation
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

include_recipe "accounts"
include_recipe "apache"
include_recipe "prometheus"
include_recipe "ruby"

username = "overpass"
basedir = data_bag_item("accounts", username)["home"]
web_passwords = data_bag_item("web", "passwords")

%w[bin site diffs db src].each do |dirname|
  directory "#{basedir}/#{dirname}" do
    owner username
    group username
    mode "755"
    recursive true
  end
end

## Install overpass from source

srcdir = "#{basedir}/src/osm-3s_v#{node[:overpass][:version]}"

package %w[
  build-essential
  libexpat1-dev
  zlib1g-dev
  liblz4-dev
  pyosmium
  osmium-tool
]

remote_file "#{srcdir}.tar.gz" do
  action :create_if_missing
  source "https://dev.overpass-api.de/releases/osm-3s_v#{node[:overpass][:version]}.tar.gz"
  owner username
  group username
  mode "644"
end

execute "source_tarball" do
  cwd "#{basedir}/src"
  command "tar -xf #{srcdir}.tar.gz"
  user username
  notifies :run, "execute[install_overpass]"
  not_if { ::File.exist?(srcdir) }
end

execute "install_overpass" do
  action :nothing
  user username
  cwd srcdir
  command "./configure --enable-lz4 --prefix=#{basedir} && make install"
  notifies :restart, "service[overpass-dispatcher]"
  notifies :restart, "service[overpass-area-dispatcher]"
end

## Setup Apache

gem_package "rotp" do
  gem_binary node[:ruby][:gem]
end

directory "#{basedir}/apache" do
  owner "root"
  group "root"
  mode "755"
end

template "#{basedir}/apache/totp-filter" do
  source "totp-filter.erb"
  owner "root"
  group "root"
  mode "755"
  variables :totp_key => web_passwords["totp_key"]
end

ssl_certificate node[:fqdn] do
  domains [node[:fqdn],
           node[:overpass][:fqdn]]
  notifies :reload, "service[apache2]"
end

apache_module "cgi"
apache_module "headers"
apache_module "rewrite"

apache_site "default" do
  action :disable
end

apache_site "#{node[:overpass][:fqdn]}" do
  template "apache.erb"
  directory "#{basedir}/site"
  variables :script_directory => "#{basedir}/cgi-bin"
end

## Overpass deamons

meta_map_short = {
  "no" => "",
  "meta" => "--meta",
  "attic" => "--attic"
}

logdir = node[:overpass][:logdir]

directory logdir do
  owner username
  group username
  mode "755"
  recursive true
end

%w[overpass-update-db overpass-update-areas].each do |fname|
  template "#{basedir}/bin/#{fname}" do
    source "#{fname}.erb"
    owner "overpass"
    group "overpass"
    mode "700"
    variables :basedir => basedir, :srcdir => srcdir
  end
end

template "#{basedir}/bin/overpass-import-db" do
  source "overpass-import-db.erb"
  owner "root"
  group "root"
  mode "755"
  variables :basedir => basedir, :username => username, :srcdir => srcdir
end

systemd_service "overpass-dispatcher" do
  description "Overpass Main Dispatcher"
  wants ["overpass-area-dispatcher.service"]
  working_directory basedir
  exec_start "#{basedir}/bin/dispatcher --osm-base #{meta_map_short[node[:overpass][:meta_mode]]} --db-dir=#{basedir}/db --rate-limit=#{node[:overpass][:rate_limit]} --space=#{node[:overpass][:dispatcher_space]}"
  exec_stop "#{basedir}/bin/dispatcher --osm-base --terminate"
  standard_output "append:#{logdir}/osm_base.log"
  user username
end

service "overpass-dispatcher" do
  action [:enable]
end

systemd_service "overpass-area-dispatcher" do
  description "Overpass Area Dispatcher"
  after ["overpass-dispatcher.service"]
  working_directory basedir
  exec_start "#{basedir}/bin/dispatcher --areas #{meta_map_short[node[:overpass][:meta_mode]]} --db-dir=#{basedir}/db"
  exec_stop "#{basedir}/bin/dispatcher --areas --terminate"
  standard_output "append:#{logdir}/areas.log"
  user username
end

service "overpass-area-dispatcher" do
  action [:enable]
end

systemd_service "overpass-update" do
  description "Overpass Update Application"
  after ["overpass-dispatcher.service"]
  wants ["overpass-area-processor.service"]
  working_directory basedir
  exec_start "#{basedir}/bin/overpass-update-db"
  standard_output "append:#{logdir}/update.log"
  user username
  restart "on-success"
end

if node[:overpass][:meta_mode] == "attic"
  systemd_service "overpass-area-processor" do
    description "Overpass Area Processor"
    after ["overpass-area-dispatcher.service", "overpass-update.service"]
    working_directory basedir
    exec_start "#{basedir}/bin/overpass-update-areas"
    standard_output "append:#{logdir}/area-processor.log"
    restart "on-success"
    nice 19
    user username
  end
else
  systemd_service "overpass-area-processor" do
    description "Overpass Area Processor"
    after ["overpass-area-dispatcher.service", "overpass-update.service"]
    working_directory basedir
    exec_start "#{basedir}/bin/osm3s_query --progress --rules"
    standard_input "file:#{srcdir}/rules/areas.osm3s"
    standard_output "append:#{logdir}/area-processor.log"
    restart "on-success"
    nice 19
    user username
  end
end

systemd_timer "overpass-area-processor" do
  action :delete
end

service "overpass-area-processor" do
  action [:disable]
end

template "/etc/logrotate.d/overpass" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode "644"
  variables :logdir => logdir
end

prometheus_exporter "overpass" do
  port 9898
  user username
  restrict_address_families "AF_UNIX"
  options [
    "--overpass.base-directory=#{basedir}"
  ]
end
