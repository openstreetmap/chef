#
# Cookbook:: web
# Recipe:: frontend
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

node.default[:memcached][:ip_address] = node.internal_ipaddress || "127.0.0.1"

include_recipe "memcached"
include_recipe "apache"
include_recipe "fail2ban"
include_recipe "web::rails"
include_recipe "web::cgimap"

web_passwords = data_bag_item("web", "passwords")

apache_module "alias"
apache_module "expires"
apache_module "headers"
apache_module "proxy"
apache_module "proxy_fcgi"
apache_module "lbmethod_byrequests"
apache_module "lbmethod_bybusyness"
apache_module "remoteip"
apache_module "reqtimeout"
apache_module "rewrite"
apache_module "unique_id"

apache_site "default" do
  action [:disable]
end

remote_directory "#{node[:web][:base_directory]}/static" do
  source "static"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "644"
end

remote_file "#{Chef::Config[:file_cache_path]}/cloudflare-ipv4-list" do
  source "https://www.cloudflare.com/ips-v4"
  compile_time true
  ignore_failure true
end

cloudflare_ipv4 = IO.read("#{Chef::Config[:file_cache_path]}/cloudflare-ipv4-list").lines.map(&:chomp)

remote_file "#{Chef::Config[:file_cache_path]}/cloudflare-ipv6-list" do
  source "https://www.cloudflare.com/ips-v6"
  compile_time true
  ignore_failure true
end

cloudflare_ipv6 = IO.read("#{Chef::Config[:file_cache_path]}/cloudflare-ipv6-list").lines.map(&:chomp)

apache_site "www.openstreetmap.org" do
  template "apache.frontend.erb"
  variables :cloudflare => cloudflare_ipv4 + cloudflare_ipv6,
            :status => node[:web][:status],
            :secret_key_base => web_passwords["secret_key_base"]
end

template "/etc/logrotate.d/apache2" do
  source "logrotate.apache.erb"
  owner "root"
  group "root"
  mode "644"
end

fail2ban_filter "apache-request-timeout" do
  failregex '^<ADDR> .* "-" 408 .*$'
end

fail2ban_jail "apache-request-timeout" do
  filter "apache-request-timeout"
  logpath "/var/log/apache2/access.log"
  ports [80, 443]
end

fail2ban_filter "apache-trackpoints-timeout" do
  failregex '^<ADDR> .* "GET /api/0\.6/trackpoints\?.*" 408 .*$'
end

fail2ban_jail "apache-trackpoints-timeout" do
  filter "apache-trackpoints-timeout"
  logpath "/var/log/apache2/access.log"
  ports [80, 443]
  bantime "12h"
  findtime "30m"
end

fail2ban_filter "apache-notes-search" do
  failregex '^<ADDR> .* "GET /api/0\.6/notes/search\?q=abcde&.*$'
end

fail2ban_jail "apache-notes-search" do
  filter "apache-notes-search"
  logpath "/var/log/apache2/access.log"
  ports [80, 443]
end

if %w[database_offline database_readonly].include?(node[:web][:status])
  service "rails-jobs@mailers" do
    action :stop
  end

  service "rails-jobs@storage" do
    action :stop
  end

  service "rails-jobs@traces" do
    action :stop
  end
else
  service "rails-jobs@mailers" do
    action [:enable, :start]
    supports :restart => true
    subscribes :restart, "rails_port[www.openstreetmap.org]"
    subscribes :restart, "systemd_service[rails-jobs@]"
  end

  service "rails-jobs@storage" do
    action [:enable, :start]
    supports :restart => true
    subscribes :restart, "rails_port[www.openstreetmap.org]"
    subscribes :restart, "systemd_service[rails-jobs@]"
  end

  service "rails-jobs@traces" do
    action [:enable, :start]
    supports :restart => true
    subscribes :restart, "rails_port[www.openstreetmap.org]"
    subscribes :restart, "systemd_service[rails-jobs@]"
  end
end

template "/usr/local/bin/deliver-message" do
  source "deliver-message.erb"
  owner "rails"
  group "rails"
  mode "0700"
  variables :secret_key_base => web_passwords["secret_key_base"]
end
