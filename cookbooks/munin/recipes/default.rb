#
# Cookbook Name:: munin
# Recipe:: default
#
# Copyright 2010, OpenStreetMap Foundation
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

package "munin-node"

service "munin-node" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
end

servers = search(:node, "recipes:munin\\:\\:server")

servers.each do |server|
  server.interfaces(:role => :external) do |interface|
    if interface[:zone]
      firewall_rule "accept-munin-#{server}" do
        action :accept
        family interface[:family]
        source "#{interface[:zone]}:#{interface[:address]}"
        dest "fw"
        proto "tcp:syn"
        dest_ports "munin"
        source_ports "1024:"
      end
    end
  end
end

template "/etc/munin/munin-node.conf" do
  source "munin-node.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables :servers => servers
  notifies :restart, resources(:service => "munin-node")
end

remote_directory "/usr/local/share/munin/plugins" do
  source "plugins"
  owner "root"
  group "root"
  mode 0755
  files_owner "root"
  files_group "root"
  files_mode 0755
  purge true
end

remote_directory "/etc/munin/plugin-conf.d" do
  source "plugin-conf.d"
  owner "root"
  group "munin"
  mode 0750
  files_owner "root"
  files_group "root"
  files_mode 0644
  purge false
  notifies :restart, resources(:service => "munin-node")
end

if Dir.glob("/proc/acpi/thermal_zone/*/temperature").empty?
  munin_plugin "acpi" do
    action :delete
  end
else
  munin_plugin "acpi"
end

# apcpdu_
munin_plugin "cpu"

if File.exists?("/sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state")
  munin_plugin "cpuspeed"
else
  munin_plugin "cpuspeed" do
    action :delete
  end
end

munin_plugin "df"
munin_plugin "df_inode"
munin_plugin "diskstats"
munin_plugin "entropy"
munin_plugin "forks"

if File.exists?("/proc/net/ip_conntrack") or File.exists?("/proc/net/nf_conntrack")
  munin_plugin "fw_conntrack"
  munin_plugin "fw_forwarded_local"
else
  munin_plugin "fw_conntrack" do
    action :delete
  end

  munin_plugin "fw_forwarded_local" do
    action :delete
  end
end

if %x{sysctl -n net.ipv4.ip_forward}.chomp == "1"
  munin_plugin "fw_packets"
else
  munin_plugin "fw_packets" do
    action :delete
  end
end

# hddtemp_smartctl

if File.exists?("/sbin/hpasmcli")
  munin_plugin "hpasmcli_temp"
  munin_plugin "hpasmcli_fans"
else
  munin_plugin "hpasmcli_temp" do
    action :delete
  end

  munin_plugin "hpasmcli_fans" do
    action :delete
  end
end

munin_plugin "http_loadtime" do
  action :delete
end

node[:network][:interfaces].each do |ifname,ifattr|
  if ifname =~ /^eth\d+$/
    if ifattr[:flags] and ifattr[:flags].include?("UP")
      munin_plugin "if_err_#{ifname}" do
        target "if_err_"
      end

      munin_plugin "if_#{ifname}" do
        target "if_"
      end
    else
      munin_plugin "if_err_#{ifname}" do
        action :delete
      end

      munin_plugin "if_#{ifname}" do
        action :delete
      end
    end
  end
end

munin_plugin "interrupts"
munin_plugin "iostat"
munin_plugin "iostat_ios"

if Dir.glob("/dev/ipmi*").empty?
  munin_plugin "ipmi_fans" do
    action :delete
  end

  munin_plugin "ipmi_temp" do
    action :delete
  end
else
  munin_plugin "ipmi_fans" do
    target "ipmi_"
  end

  munin_plugin "ipmi_temp" do
    target "ipmi_"
  end
end

munin_plugin "irqstats"

Dir.new("/sys/block").each do |device|
  if device.match(/^sd/)
    munin_plugin "linux_diskstat_iops_#{device}" do
      target "linux_diskstat_"
    end

    munin_plugin "linux_diskstat_latency_#{device}" do
      target "linux_diskstat_"
    end

    munin_plugin "linux_diskstat_throughput_#{device}" do
      target "linux_diskstat_"
    end
  end
end

munin_plugin "load"
munin_plugin "memory"
munin_plugin "netstat"

if File.exists?("/proc/net/rpc/nfs")
  munin_plugin "nfs4_client"
else
  munin_plugin "nfs4_client" do
    action :delete
  end
end

if File.exists?("/proc/net/rpc/nfsd")
  munin_plugin "nfsd"
  munin_plugin "nfsd4"
else
  munin_plugin "nfsd" do
    action :delete
  end

  munin_plugin "nfsd4" do
    action :delete
  end
end

munin_plugin "open_files"
munin_plugin "open_inodes"

munin_plugin "postfix_mailqueue" do
  action :delete
end

munin_plugin "postfix_mailvolume" do
  action :delete
end

munin_plugin "processes"
munin_plugin "proc_pri"

Dir.glob("/sys/class/hwmon/hwmon*").each do |hwmon|
  hwmon = "#{hwmon}/device" unless File.exists?("#{hwmon}/name")

  if Dir.glob("#{hwmon}/fan*_input").empty?
    munin_plugin "sensors_fan" do
      action :delete
    end
  else
    munin_plugin "sensors_fan" do
      target "sensors_"
    end
  end

  if Dir.glob("#{hwmon}/temp*_input").empty?
    munin_plugin "sensors_temp" do
      action :delete
    end
  else
    munin_plugin "sensors_temp" do
      target "sensors_"
    end
  end

  if Dir.glob("#{hwmon}/in*_input").empty?
    munin_plugin "sensors_volt" do
      action :delete
    end
  else
    munin_plugin "sensors_volt" do
      target "sensors_"
    end
  end
end

# smart_
munin_plugin "swap"
munin_plugin "threads"
munin_plugin "uptime"
munin_plugin "users"
munin_plugin "vmstat"
