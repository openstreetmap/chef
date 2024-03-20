#
# Cookbook:: exim
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

include_recipe "networking"
include_recipe "prometheus"

package %w[
  exim4
  openssl
  ssl-cert
  mailutils
]

package "exim4-daemon-heavy" do
  only_if { ::File.exist?("/var/run/clamav/clamd.ctl") }
end

group "Debian-exim" do
  action :modify
  members "clamav"
  append true
  only_if { ::File.exist?("/var/run/clamav/clamd.ctl") }
end

group "ssl-cert" do
  action :modify
  members "Debian-exim"
  append true
end

if node[:exim][:certificate_names]
  include_recipe "apache"

  apache_site node[:exim][:certificate_names].first do
    template "apache.erb"
    variables :aliases => node[:exim][:certificate_names].drop(1)
  end

  ssl_certificate node[:exim][:certificate_names].first do
    domains node[:exim][:certificate_names]
    notifies :restart, "service[exim4]"
  end
else
  openssl_x509_certificate "/etc/ssl/certs/exim.pem" do
    key_file "/etc/ssl/private/exim.key"
    owner "root"
    group "ssl-cert"
    mode "640"
    org "OpenStreetMap"
    email "postmaster@openstreetmap.org"
    common_name node[:fqdn]
    expire 3650
    notifies :restart, "service[exim4]"
  end
end

service "exim4" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

relay_to_domains = node[:exim][:relay_to_domains]

node[:exim][:routes].each_value do |route|
  relay_to_domains |= route[:domains] if route[:host]
end

relay_from_hosts = node[:exim][:relay_from_hosts]

if node[:exim][:smarthost_name]
  search(:node, "exim_smarthost_via:*?").each do |host|
    relay_from_hosts |= host.ipaddresses(:role => :external)
  end

  domains = node[:exim][:certificate_names].select { |c| c =~ /^a\.mx\./ }.collect { |c| c.sub(/^a\.mx./, "") }
  primary_domain = domains.first

  directory "/srv/mta-sts.#{primary_domain}" do
    owner "root"
    group "root"
    mode "755"
  end

  domains.each do |domain|
    template "/srv/mta-sts.#{primary_domain}/#{domain}.txt" do
      source "mta-sts.erb"
      owner "root"
      group "root"
      mode "644"
      variables :domain => domain
    end
  end

  ssl_certificate "mta-sts.#{primary_domain}" do
    domains domains.collect { |d| "mta-sts.#{d}" }
    notifies :reload, "service[apache2]"
  end

  apache_site "mta-sts.#{primary_domain}" do
    template "apache-mta-sts.erb"
    directory "/srv/mta-sts.#{primary_domain}"
    variables :domains => domains
  end
end

file "/etc/exim4/blocked-senders" do
  owner "root"
  group "Debian-exim"
  mode "644"
end

file "/etc/exim4/blocked-sender-domains" do
  owner "root"
  group "Debian-exim"
  mode "644"
end

file "/etc/exim4/detaint" do
  owner "root"
  group "Debian-exim"
  mode "644"
  content "*"
end

if node[:exim][:dkim_selectors]
  keys = data_bag_item("exim", "dkim")

  template "/etc/exim4/dkim-domains" do
    owner "root"
    source "dkim-domains.erb"
    group "Debian-exim"
    mode "644"
  end

  template "/etc/exim4/dkim-selectors" do
    owner "root"
    source "dkim-selectors.erb"
    group "Debian-exim"
    mode "644"
  end

  directory "/etc/exim4/dkim-keys" do
    owner "root"
    group "Debian-exim"
    mode "755"
  end

  node[:exim][:dkim_selectors].each do |domain, _selector|
    file "/etc/exim4/dkim-keys/#{domain}" do
      content keys[domain].join("\n")
      owner "root"
      group "Debian-exim"
      mode "640"
    end
  end
end

template "/etc/default/exim4" do
  source "default.erb"
  owner "root"
  group "root"
  mode "044"
  notifies :restart, "service[exim4]"
end

template "/etc/exim4/exim4.conf" do
  source "exim4.conf.erb"
  owner "root"
  group "Debian-exim"
  mode "644"
  variables :relay_to_domains => relay_to_domains.sort,
            :relay_from_hosts => relay_from_hosts.sort
  notifies :restart, "service[exim4]"
end

search(:accounts, "*:*").each do |account|
  name = account["id"]
  details = node[:accounts][:users][name] || {}

  if details[:status] && account["email"]
    node.default[:exim][:aliases][name] = account["email"]
  end
end

if node[:exim][:private_aliases]
  aliases = data_bag_item("exim", "aliases")

  aliases[node[:exim][:private_aliases]].each do |name, address|
    node.default[:exim][:aliases][name] = address
  end
end

template "/etc/aliases" do
  source "aliases.erb"
  owner "root"
  group "root"
  mode "644"
end

remote_directory "/etc/exim4/noreply" do
  source "noreply"
  owner "root"
  group "Debian-exim"
  mode "755"
  files_owner "root"
  files_group "Debian-exim"
  files_mode "755"
  purge true
end

template "/etc/mail.rc" do
  source "mail.rc.erb"
  owner "root"
  group "root"
  mode "644"
end

prometheus_exporter "exim" do
  port 9636
  user "Debian-exim"
  protect_proc "default"
end

if node[:exim][:smarthost_name]
  firewall_rule "accept-inbound-smtp" do
    action :accept
    context :incoming
    protocol :tcp
    dest_ports node[:exim][:daemon_smtp_ports]
    source_ports "1024-65535"
  end
else
  smarthosts = []

  search(:node, "exim_smarthost_name:*?").each do |host|
    smarthosts |= host.ipaddresses(:role => :external)
  end

  firewall_rule "accept-inbound-smtp" do
    action :accept
    context :incoming
    protocol :tcp
    source smarthosts
    dest_ports node[:exim][:daemon_smtp_ports]
    source_ports "1024-65535"
    not_if { smarthosts.empty? }
  end
end

if node[:exim][:smarthost_via]
  firewall_rule "deny-outbound-smtp" do
    action :reject
    context :outgoing
    protocol :tcp
    dest_ports "smtp"
  end
end
