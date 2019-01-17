#
# Cookbook Name:: squid
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

if node[:squid][:version] == "3"
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
  mode 0o644
end

directory "/etc/squid/squid.conf.d" do
  owner "root"
  group "root"
  mode 0o755
end

if node[:squid][:cache_dir] =~ /^coss (\S+) /
  cache_dir = File.dirname(Regexp.last_match(1))
elsif node[:squid][:cache_dir] =~ /^\S+ (\S+) /
  cache_dir = Regexp.last_match(1)
end

directory cache_dir do
  owner "proxy"
  group "proxy"
  mode 0o750
  recursive true
end

systemd_tmpfile "/var/run/squid" do
  type "d"
  owner "proxy"
  group "proxy"
  mode "0755"
end

systemd_service "squid" do
  description "Squid caching proxy"
  after ["network.target", "nss-lookup.target"]
  type "forking"
  limit_nofile 98304
  exec_start_pre "/usr/sbin/squid -N -z"
  exec_start "/usr/sbin/squid -Y"
  exec_reload "/usr/sbin/squid -k reconfigure"
  exec_stop "/usr/sbin/squid -k shutdown"
  private_tmp true
  private_devices true
  protect_system "full"
  protect_home true
  restart "on-failure"
  timeout_sec 0
end

service "squid" do
  action [:enable, :start]
  subscribes :restart, "systemd_service[squid]"
  subscribes :restart, "directory[#{cache_dir}]"
  subscribes :reload, "template[/etc/squid/squid.conf]"
  subscribes :reload, "template[/etc/resolv.conf]"
end

log "squid-restart" do
  message "Restarting squid due to counter wraparound"
  notifies :restart, "service[squid]"
  only_if do
    IO.popen(["squidclient", "--host=127.0.0.1", "--port=80", "mgr:counters"]) do |io|
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
