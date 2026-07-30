#
# Cookbook:: chef
# Recipe:: server
#
# Copyright:: 2010, OpenStreetMap Foundation
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

include_recipe "apache"
include_recipe "chef::knife"

# cache_dir = Chef::Config[:file_cache_path]
#
# cinc_version = node[:chef][:server][:version]
#
# cinc_package = "cinc-server-core_#{cinc_version}-1_amd64.deb"
#
# os_release = node[:lsb][:release]
#
# Dir.glob("#{cache_dir}/cinc-server-core_*.deb").each do |deb|
#   next if deb == "#{cache_dir}/#{cinc_package}"
#
#   file deb do
#     action :delete
#     backup false
#   end
# end
#
# remote_file "#{cache_dir}/#{cinc_package}" do
#   source "https://downloads.cinc.sh/files/stable/cinc-server/#{cinc_version}/debian/#{os_release}/cinc-server-core_#{cinc_version}-1_amd64.deb"
#   owner "root"
#   group "root"
#   mode 0644
#   backup false
# end
#
# dpkg_package "cinc-server-core" do
#   source "#{cache_dir}/#{cinc_package}"
#   version "#{cinc_version}-1"
#   notifies :run, "execute[cinc-server-reconfigure]"
# end

template "/etc/cinc-project/cinc-server.rb" do
  source "server.rb.erb"
  owner "root"
  group "root"
  mode "640"
  notifies :run, "execute[cinc-server-reconfigure]"
end

execute "cinc-server-reconfigure" do
  action :nothing
  command "cinc-server-ctl reconfigure"
  user "root"
  group "root"
end

execute "cinc-server-restart" do
  action :nothing
  command "cinc-server-ctl restart"
  user "root"
  group "root"
end

systemd_service "cinc-server" do
  description "CINC server"
  after "network.target"
  exec_start "/opt/cinc-project/embedded/bin/runsvdir-start"
end

service "cinc-server" do
  action [:enable, :start]
  subscribes :restart, "systemd_service[cinc-server]"
end

apache_module "alias"
apache_module "proxy_http"

ssl_certificate "chef.openstreetmap.org" do
  domains ["chef.openstreetmap.org", "chef.osm.org"]
  notifies :reload, "service[apache2]"
  notifies :run, "execute[cinc-server-restart]"
end

apache_site "chef.openstreetmap.org" do
  template "apache.erb"
end

template "/etc/cron.daily/cinc-server-backup" do
  source "server-backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end
