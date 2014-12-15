#
# Cookbook Name:: geodns
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

service "pdns" do
  action [ :stop, :disable ]
  supports :status => true, :restart => true, :reload => true
end

file "/etc/powerdns/countries.conf" do
  action :delete
end

file "/etc/powerdns/pdns.d/pdns.simplebind" do
  action :delete
  notifies :reload, "service[pdns]"
end

file "/etc/powerdns/pdns.d/geo.conf" do
  action :delete
end

file "/etc/powerdns/zones.d/tile.conf" do
  action :delete
end

directory "/etc/powerdns/zones.d" do
  action :delete
end

file "/etc/cron.weekly/geodns-update" do
  action :delete
end

package "pdns-backend-geo" do
  action :purge
end

package "pdns-server" do
  action :purge
end

package "geoip-database-contrib"

package "gdnsd"

service "gdnsd" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
end

template "/etc/gdnsd/config" do
  source "config.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[gdnsd]"
end

template "/etc/gdnsd/zones/geo.openstreetmap.org" do
  source "geo.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[gdnsd]"
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
