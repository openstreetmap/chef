#
# Cookbook:: tilecache
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

require "ipaddr"

include_recipe "fail2ban"
include_recipe "munin"
include_recipe "nginx"
include_recipe "squid"
include_recipe "ssl"

package "apache2" do
  action :remove
end

package %w[
  curl
  xz-utils
  openssl
]

# oathtool for QoS token
package "oathtool"

tilecaches = search(:node, "roles:tilecache").sort_by { |n| n[:hostname] }
tilerenders = search(:node, "roles:tile").sort_by { |n| n[:hostname] }

web_passwords = data_bag_item("web", "passwords")

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

    firewall_rule "accept-squid-htcp" do
      action :accept
      family "inet"
      source "net:#{address}"
      dest "fw"
      proto "udp"
      dest_ports "4827"
      source_ports "4827"
    end

    firewall_rule "accept-squid-htcp-reply" do
      action :accept
      family "inet"
      source "fw"
      dest "net:#{address}"
      proto "udp"
      dest_ports "4827"
      source_ports "4827"
    end
  end
end

squid_fragment "tilecache" do
  template "squid.conf.erb"
  variables :caches => tilecaches, :renders => tilerenders
end

package "rsync"

template "/etc/logrotate.d/squid" do
  source "logrotate.squid.erb"
  owner "root"
  group "root"
  mode 0o644
end

nginx_site "default" do
  action [:delete]
end

template "/usr/local/bin/nginx_generate_tilecache_qos_map" do
  source "nginx_generate_tilecache_qos_map.erb"
  owner "root"
  group "root"
  mode 0o750
  variables :totp_key => web_passwords["totp_key"]
end

template "/etc/cron.d/tilecache" do
  source "cron.erb"
  owner "root"
  group "root"
  mode 0o644
end

execute "execute_nginx_generate_tilecache_qos_map" do
  command "/usr/local/bin/nginx_generate_tilecache_qos_map"
  creates "/etc/nginx/conf.d/tile_qos_rates.map"
  action :run
end

ssl_certificate "tile.openstreetmap.org" do
  domains ["tile.openstreetmap.org",
           "a.tile.openstreetmap.org",
           "b.tile.openstreetmap.org",
           "c.tile.openstreetmap.org",
           "tile.osm.org",
           "a.tile.osm.org",
           "b.tile.osm.org",
           "c.tile.osm.org"]
  notifies :restart, "service[nginx]"
end

nginx_site "tile" do
  template "nginx_tile.conf.erb"
  variables :caches => tilecaches
end

template "/etc/logrotate.d/nginx" do
  source "logrotate.nginx.erb"
  owner "root"
  group "root"
  mode 0o644
end

fail2ban_jail "squid" do
  maxretry 1000
end

tilerenders.each do |render|
  munin_plugin "ping_#{render[:fqdn]}" do
    target "ping_"
    conf "munin.ping.erb"
    conf_variables :host => render[:fqdn]
  end
end

template "/etc/cron.d/tilecache" do
  source "cron.erb"
  owner "root"
  group "root"
  mode 0o644
end

directory "/srv/tilecache" do
  owner "root"
  group "root"
  mode 0o755
end

directory "/srv/tilecache/data" do
  owner "www-data"
  group "www-data"
  mode 0o755
end

cookbook_file "/srv/tilecache/tilecache-curl-time.txt" do
  source "tilecache-curl-time.txt"
  owner "root"
  group "root"
  mode 0o755
end

template "/srv/tilecache/tilecache-curl-time" do
  source "tilecache-curl-time.erb"
  owner "root"
  group "root"
  mode 0o755
  variables :caches => tilecaches, :renders => tilerenders
end

template "/srv/tilecache/tilecache-fastest-peers" do
  source "tilecache-fastest-peers.erb"
  owner "root"
  group "root"
  mode 0o755
end
