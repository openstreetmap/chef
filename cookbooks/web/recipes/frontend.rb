#
# Cookbook Name:: web
# Recipe:: frontend
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

include_recipe "memcached"
include_recipe "apache::ssl"
include_recipe "web::rails"
include_recipe "web::cgimap"

web_passwords = data_bag_item("web", "passwords")

apache_module "alias"
apache_module "deflate"
apache_module "expires"
apache_module "headers"
apache_module "proxy_fcgi"
apache_module "proxy_http"
apache_module "proxy_balancer"
apache_module "lbmethod_byrequests"
apache_module "lbmethod_bybusyness"
apache_module "rewrite"

apache_site "default" do
  action [:disable]
end

apache_site "www.openstreetmap.org" do
  template "apache.frontend.erb"
  variables :secret_key_base => web_passwords["secret_key_base"]
end

gem_package "hpricot"
gem_package "home_run"
gem_package "apachelogregex"

template "/etc/logrotate.d/apache2" do
  source "logrotate.apache.erb"
  owner "root"
  group "root"
  mode 0644
end

munin_plugin "api_calls_num" do
  action :delete
end

munin_plugin "api_calls_#{node[:hostname]}" do
  target "api_calls_"
end

munin_plugin "api_waits_#{node[:hostname]}" do
  target "api_waits_"
end

node.set[:memcached][:ip_address] = node.external_ipaddress

firewall_rule "accept-memcache-tcp" do
  action :accept
  family "inet"
  source "ic"
  dest "fw"
  proto "tcp"
  dest_ports "11211"
  source_ports "1024:"
end

firewall_rule "accept-memcache-udp" do
  action :accept
  family "inet"
  source "ic"
  dest "fw"
  proto "udp"
  dest_ports "11211"
  source_ports "1024:"
end
