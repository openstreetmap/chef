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
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "squid"
package "squidclient"

template "/etc/squid/squid.conf" do
  source "squid.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/default/squid" do
  source "squid.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/etc/squid/squid.conf.d" do
  owner "root"
  group "root"
  mode 0755
end

if node[:lsb][:release].to_f >= 15.10
  systemd_service "squid" do
    description "Squid caching proxy"
    after ["network.target", "nss-lookup.target"]
    limit_nofile 65536
    environment "SQUID_ARGS" => "-D"
    environment_file "/etc/default/squid"
    exec_start_pre "/usr/sbin/squid $SQUID_ARGS -z"
    exec_start "/usr/sbin/squid -N $SQUID_ARGS"
    exec_reload "/usr/sbin/squid -k reconfigure"
    exec_stop "/usr/sbin/squid -k shutdown"
    restart "on-failure"
    timeout_sec 0
  end

  service "squid" do
    provider Chef::Provider::Service::Systemd
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
    subscribes :restart, "systemd_service[squid]"
    subscribes :reload, "template[/etc/squid/squid.conf]"
    subscribes :restart, "template[/etc/default/squid]"
    subscribes :reload, "template[/etc/resolv.conf]"
  end
else
  service "squid" do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
    subscribes :reload, "template[/etc/squid/squid.conf]"
    subscribes :restart, "template[/etc/default/squid]"
    subscribes :reload, "template[/etc/resolv.conf]"
  end
end

munin_plugin "squid_cache"
munin_plugin "squid_delay_pools"
munin_plugin "squid_times"
munin_plugin "squid_icp"
munin_plugin "squid_objectsize"
munin_plugin "squid_requests"
munin_plugin "squid_traffic"
