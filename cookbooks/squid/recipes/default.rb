#
# Cookbook:: squid
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

include_recipe "apt"
include_recipe "munin"
include_recipe "prometheus"

if node[:squid][:version] >= 3
  apt_package "squid" do
    action :unlock
  end

  apt_package "squid-common" do
    action :unlock
  end

  apt_package "squid" do
    action :purge
    only_if "dpkg-query -W squid | fgrep -q 2."
  end

  apt_package "squid-common" do
    action :purge
    only_if "dpkg-query -W squid-common | fgrep -q 2."
  end

  file "/store/squid/coss-01" do
    action :delete
    backup false
  end

  package "squidclient" do
    action :upgrade
  end
end

package "squid"
package "squidclient"

template "/etc/squid/squid.conf" do
  source "squid.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/etc/squid/squid.conf.d" do
  owner "root"
  group "root"
  mode "755"
end

Array(node[:squid][:cache_dir]).each do |cache_dir|
  if cache_dir =~ /^coss (\S+) /
    cache_dir = File.dirname(Regexp.last_match(1))
  elsif cache_dir =~ /^\S+ (\S+) /
    cache_dir = Regexp.last_match(1)
  end

  directory cache_dir do
    owner "proxy"
    group "proxy"
    mode "750"
    recursive true
    notifies :restart, "service[squid]"
  end
end

systemd_tmpfile "/var/run/squid" do
  type "d"
  owner "proxy"
  group "proxy"
  mode "0755"
end

address_families = %w[AF_UNIX AF_INET AF_INET6]

file "/etc/systemd/system/squid.service" do
  action :delete
end

file "/etc/logrotate.d/squid.dpkg-dist" do
  action :delete
end

squid_service_exec = if node[:lsb][:release].to_f < 20.04
                       "/usr/sbin/squid -YC"
                     else
                       "/usr/sbin/squid --foreground -YC"
                     end

systemd_service "squid" do
  dropin "chef"
  limit_nofile 98304
  private_tmp true
  private_devices node[:squid][:private_devices]
  protect_system "full"
  protect_home true
  restrict_address_families address_families
  restart "always"
  exec_start "#{squid_service_exec}"
end

service "squid" do
  action :enable
  subscribes :restart, "systemd_service[squid]"
  subscribes :restart, "template[/etc/squid/squid.conf]"
  subscribes :reload, "template[/etc/resolv.conf]"
end

notify_group "squid-start" do
  action :run
  notifies :start, "service[squid]"
end

service "squid-restart" do
  service_name "squid"
  action :restart
  only_if do
    IO.popen(["squidclient", "--host=127.0.0.1", "--port=3128", "mgr:counters"]) do |io|
      io.each.grep(/^[a-z][a-z_.]+ = -[0-9]+$/).count.positive?
    end
  end
end

munin_plugin "squid_cache"
munin_plugin "squid_times"
munin_plugin "squid_icp"
munin_plugin "squid_objectsize"
munin_plugin "squid_requests"
munin_plugin "squid_traffic"

munin_plugin "squid_delay_pools" do
  action :delete
end

munin_plugin "squid_delay_pools_noreferer" do
  action :delete
end

prometheus_exporter "squid" do
  port 9301
  listen_switch "listen"
end
