#
# Cookbook:: geodns
# Recipe:: default
#
# Copyright:: 2011, OpenStreetMap Foundation
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

include_recipe "geoipupdate"

package %w[
  gdnsd
]

directory "/etc/gdnsd/config.d" do
  owner "nobody"
  group "nogroup"
  mode "755"
end

%w[tile nominatim].each do |zone|
  %w[map resource weighted].each do |type|
    template "/etc/gdnsd/config.d/#{zone}.#{type}" do
      action :create_if_missing
      source "zone.#{type}.erb"
      owner "nobody"
      group "nogroup"
      mode "644"
      variables :zone => zone
    end
  end
end

template "/etc/gdnsd/config" do
  source "config.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[gdnsd]"
end

template "/etc/gdnsd/zones/geo.openstreetmap.org" do
  source "geo.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[gdnsd]"
end

service "gdnsd" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

systemd_service "gdnsd-reload" do
  description "Reload gdnsd configuration"
  type "simple"
  user "root"
  exec_start "/bin/systemctl reload-or-restart gdnsd"
  standard_output "null"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  no_new_privileges true
end

systemd_path "gdnsd-reload" do
  description "Reload gdnsd configuration"
  path_changed "/etc/gdnsd/config.d"
end

service "gdnsd-reload.path" do
  action [:enable, :start]
  subscribes :restart, "systemd_path[gdnsd-reload]"
end

firewall_rule "accept-dns-udp" do
  action :accept
  source "net"
  dest "fw"
  proto "udp"
  dest_ports "domain"
end

firewall_rule "accept-dns-tcp" do
  action :accept
  source "net"
  dest "fw"
  proto "tcp:syn"
  dest_ports "domain"
end
