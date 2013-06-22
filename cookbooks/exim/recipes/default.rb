#
# Cookbook Name:: exim
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

include_recipe "networking"
include_recipe "ssl"

package "exim4"

if File.exist?("/var/run/clamav/clamd.ctl")
  package "exim4-daemon-heavy"
end

group "ssl-cert" do
  action :modify
  members "Debian-exim"
  append true
end

service "exim4" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
  subscribes :restart, resources(:cookbook_file => "/etc/ssl/certs/openstreetmap.pem")
  subscribes :restart, resources(:file => "/etc/ssl/private/openstreetmap.key")
end

relay_to_domains = node[:exim][:relay_to_domains]

node[:exim][:routes].each_value do |route|
  relay_to_domains = relay_to_domains | route[:domains]
end

relay_from_hosts = node[:exim][:relay_from_hosts]

if node[:exim][:smarthost_name]
  search(:node, "exim_smarthost_via:#{node[:exim][:smarthost_name]}\\:*").each do |host|
    relay_from_hosts = relay_from_hosts | host.ipaddresses(:role => :external)
  end
end

template "/etc/exim4/exim4.conf" do
  source "exim4.conf.erb"
  owner "root"
  group "Debian-exim"
  mode 0644
  variables :relay_to_domains => relay_to_domains.sort,
            :relay_from_hosts => relay_from_hosts.sort
  notifies :restart, resources(:service => "exim4")
end

search(:accounts, "*:*").each do |account|
  name = account["id"]
  details = node[:accounts][:users][name] || {}

  if details[:status] and account["email"]
    node.default[:exim][:aliases][name] = account["email"]
  end
end

template "/etc/aliases" do
  source "aliases.erb"
  owner "root"
  group "root"
  mode 0644
end

remote_directory "/etc/exim4/noreply" do
  source "noreply"
  owner "root"
  group "Debian-exim"
  mode 0755
  files_owner "root"
  files_group "Debian-exim"
  files_mode 0755
  purge true
end

munin_plugin "exim_mailqueue"
munin_plugin "exim_mailstats"

if not relay_to_domains.empty? or not node[:exim][:local_domains].empty?
  node[:exim][:daemon_smtp_ports].each do |port|
    firewall_rule "accept-inbound-smtp-#{port}" do
      action :accept
      source "net"
      dest "fw"
      proto "tcp:syn"
      dest_ports port
      source_ports "1024:"
    end
  end
end

if node[:exim][:smarthost_via]
  firewall_rule "deny-outbound-smtp" do
    action :reject
    source "fw"
    dest "net"
    proto "tcp:syn"
    dest_ports "smtp"
  end
end
