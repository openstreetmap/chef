#
# Cookbook Name:: tilecache
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

node.default[:ssl][:certificates] = node[:ssl][:certificates] | [ "tile.openstreetmap" ]

include_recipe "ssl"
include_recipe "squid"
include_recipe "nginx"

package "xz-utils"

tilecaches = search(:node, "roles:tilecache").sort_by { |n| n[:hostname] }
tilerenders = search(:node, "roles:tile").sort_by { |n| n[:hostname] }

tilecaches.each do |cache|
  cache.ipaddresses(:family => :inet, :role => :external).sort.each do |address|
    firewall_rule "accept-squid" do
      action :accept
      family "inet"
      source "net:#{address}"
      dest "fw"
      proto "tcp:syn"
      dest_ports "3128"
      source_ports "1024:"
    end
    firewall_rule "accept-squid-icp" do
      action :accept
      family "inet"
      source "net:#{address}"
      dest "fw"
      proto "udp"
      dest_ports "3130"
      source_ports "3130"
    end
    firewall_rule "accept-squid-icp-reply" do
      action :accept
      family "inet"
      source "fw"
      dest "net:#{address}"
      proto "udp"
      dest_ports "3130"
      source_ports "3130"
    end
  end
end

squid_fragment "tilecache" do
  template "squid.conf.erb"
  variables :caches => tilecaches, :renders => tilerenders
end

template "/etc/logrotate.d/squid" do
  source "logrotate.squid.erb"
  owner "root"
  group "root"
  mode 0644
end

nginx_site "default" do
  action [ :delete ]
end

nginx_site "tile-ssl" do
  template "nginx_tile_ssl.conf.erb"
end

tilerenders.each do |render|
  munin_plugin "ping_#{render[:fqdn]}" do
    target "ping_"
    conf "munin.ping.erb"
    conf_variables :host => render[:fqdn]
  end
end
