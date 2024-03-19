#
# Cookbook:: apache
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

include_recipe "fail2ban"
include_recipe "prometheus"
include_recipe "ssl"

package %w[
  apache2
  libwww-perl
]

%w[event itk prefork worker].each do |mpm|
  next if mpm == node[:apache][:mpm]

  apache_module "mpm_#{mpm}" do
    action [:disable]
  end
end

apache_module "mpm_#{node[:apache][:mpm]}" do
  action [:enable]
end

apache_module "http2"

admins = data_bag_item("apache", "admins")

apache_conf "httpd" do
  template "httpd.conf.erb"
  notifies :reload, "service[apache2]"
end

template "/etc/apache2/ports.conf" do
  source "ports.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

systemd_service "apache2" do
  dropin "chef"
  memory_high "50%"
  memory_max "75%"
  notifies :restart, "service[apache2]"
end

apache_module "info" do
  conf "info.conf.erb"
  variables :hosts => admins["hosts"]
end

apache_module "status" do
  conf "status.conf.erb"
  variables :hosts => admins["hosts"]
end

if node[:apache][:evasive][:enable]
  apache_module "evasive" do
    conf "evasive.conf.erb"
  end
else
  apache_module "evasive" do
    action :disable
  end
end

apache_module "brotli" do
  conf "brotli.conf.erb"
end

apache_module "deflate" do
  conf "deflate.conf.erb"
end

apache_module "headers"
apache_module "ssl"

apache_conf "ssl" do
  template "ssl.erb"
end

# Apache should only be started after modules enabled
service "apache2" do
  action [:enable, :start]
  retries 2
  retry_delay 10
  supports :status => true, :restart => true, :reload => true
end

fail2ban_filter "apache-forbidden" do
  action :delete
end

fail2ban_jail "apache-forbidden" do
  action :delete
end

fail2ban_filter "apache-evasive" do
  failregex ": Blacklisting address <ADDR>: possible DoS attack\.$"
end

fail2ban_jail "apache-evasive" do
  filter "apache-evasive"
  backend "systemd"
  journalmatch "_SYSTEMD_UNIT=apache2.service SYSLOG_IDENTIFIER=mod_evasive"
  ports [80, 443]
  findtime "10m"
  maxretry 3
end

template "/var/lib/prometheus/node-exporter/apache.prom" do
  source "apache.prom.erb"
  owner "root"
  group "root"
  mode "644"
end

prometheus_exporter "apache" do
  port 9117
  options "--scrape_uri=http://localhost/server-status?auto"
end
