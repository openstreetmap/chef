#
# Cookbook:: munin
# Recipe:: default
#
# Copyright:: 2010, OpenStreetMap Foundation
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

include_recipe "munin"

remote_directory "/usr/local/share/munin/plugins" do
  source "plugins"
  owner "root"
  group "root"
  mode "755"
  files_owner "root"
  files_group "root"
  files_mode "755"
  purge true
end

remote_directory "/etc/munin/plugin-conf.d" do
  source "plugin-conf.d"
  owner "root"
  group "munin"
  mode "750"
  files_owner "root"
  files_group "root"
  files_mode "644"
  purge false
  notifies :restart, "service[munin-node]"
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

if File.exist?("/sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state")
  munin_plugin "cpuspeed"
else
  munin_plugin "cpuspeed" do
    action :delete
  end
end

munin_plugin_conf "df" do
  template "df.erb"
end

munin_plugin "df"
munin_plugin "df_inode"

munin_plugin_conf "diskstats" do
  template "diskstats.erb"
end

munin_plugin "diskstats"
munin_plugin "entropy"
munin_plugin "forks"

if node[:kernel][:modules].include?("nf_conntrack")
  package "conntrack"

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

if File.read("/proc/sys/net/ipv4/ip_forward").chomp == "1"
  munin_plugin "fw_packets"
else
  munin_plugin "fw_packets" do
    action :delete
  end
end

if File.exist?("/sbin/hpasmcli")
  munin_plugin "hpasmcli2_temp" do
    target "hpasmcli2_"
  end

  munin_plugin "hpasmcli2_fans" do
    target "hpasmcli2_"
  end
else
  munin_plugin "hpasmcli2_temp" do
    action :delete
  end

  munin_plugin "hpasmcli2_fans" do
    action :delete
  end
end

munin_plugin "hpasmcli_temp" do
  action :delete
end

munin_plugin "hpasmcli_fans" do
  action :delete
end

munin_plugin "http_loadtime" do
  action :delete
end

node[:network][:interfaces].each do |ifname, ifattr|
  if ifattr[:flags]&.include?("UP") && !ifattr[:flags].include?("LOOPBACK")
    if node[:hardware] &&
       node[:hardware][:network] &&
       node[:hardware][:network][ifname][:device] =~ /^virtio/
      munin_plugin_conf "if_#{ifname}" do
        template "if.erb"
        variables :ifname => ifname
      end
    else
      munin_plugin_conf "if_#{ifname}" do
        action :delete
      end
    end

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

munin_plugin "interrupts"
munin_plugin "iostat"
munin_plugin "iostat_ios"

if Dir.glob("/dev/ipmi*").empty?
  munin_plugin_conf "ipmi" do
    action :delete
  end

  munin_plugin "ipmi_fans" do
    action :delete
  end

  munin_plugin "ipmi_temp" do
    action :delete
  end

  munin_plugin "ipmi_power" do
    action :delete
  end
else
  munin_plugin_conf "ipmi" do
    template "ipmi.erb"
  end

  munin_plugin "ipmi_fans" do
    target "ipmi_"
  end

  munin_plugin "ipmi_temp" do
    target "ipmi_"
  end

  munin_plugin "ipmi_power" do
    target "ipmi_"
  end
end

munin_plugin "irqstats"
munin_plugin "load"
munin_plugin "memory"
munin_plugin "netstat"

if node[:kernel][:modules].include?("nfsv3")
  munin_plugin "nfs_client"
else
  munin_plugin "nfs_client" do
    action :delete
  end
end

if node[:kernel][:modules].include?("nfsv4")
  munin_plugin "nfs4_client"
else
  munin_plugin "nfs4_client" do
    action :delete
  end
end

if node[:kernel][:modules].include?("nfsd")
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

sensors_fan = false
sensors_temp = false
sensors_volt = false

Dir.glob("/sys/class/hwmon/hwmon*").each do |hwmon|
  hwmon = "#{hwmon}/device" unless File.exist?("#{hwmon}/name")

  sensors_fan = true unless Dir.glob("#{hwmon}/fan*_input").empty?
  sensors_temp = true unless Dir.glob("#{hwmon}/temp*_input").empty?
  sensors_volt = true unless Dir.glob("#{hwmon}/in*_input").empty?
end

package "lm-sensors" if sensors_fan || sensors_temp || sensors_volt

if sensors_fan
  munin_plugin "sensors_fan" do
    target "sensors_"
  end
else
  munin_plugin "sensors_fan" do
    action :delete
  end
end

if sensors_temp
  munin_plugin "sensors_temp" do
    target "sensors_"
  end
else
  munin_plugin "sensors_temp" do
    action :delete
  end
end

if sensors_volt
  munin_plugin "sensors_volt" do
    target "sensors_"
    conf "sensors_volt.erb"
  end
else
  munin_plugin "sensors_volt" do
    action :delete
  end
end

munin_plugin "swap"
munin_plugin "tcp"
munin_plugin "threads"
munin_plugin "uptime"
munin_plugin "users"
munin_plugin "vmstat"
