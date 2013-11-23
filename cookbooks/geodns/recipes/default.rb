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

package "pdns-server"
package "pdns-backend-geo"

service "pdns" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
end

file "/etc/powerdns/pdns.d/pdns.simplebind" do
  action :delete
  notifies :reload, "service[pdns]"
end

template "/etc/powerdns/pdns.d/geo.conf" do
  source "geo.conf.erb"
  owner "root"
  group "root"
  mode "0600"
  notifies :reload, "service[pdns]"
end

directory "/etc/powerdns/zones.d" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/powerdns/zones.d/tile.conf" do
  source "tile.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[pdns]"
end

template "/etc/cron.weekly/geodns-update" do
  source "cron.erb"
  owner "root"
  group "root"
  mode "0755"
end

execute "geodns-sync-countries" do
  command "rsync -z rsync://countries-ns.mdc.dk/zone/zz.countries.nerd.dk.rbldnsd /etc/powerdns/countries.conf"
  user "root"
  group "root"
  not_if { File.exist?("/etc/powerdns/countries.conf") }
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
