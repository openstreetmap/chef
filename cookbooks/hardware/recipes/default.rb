#
# Cookbook Name:: hardware
# Recipe:: default
#
# Copyright 2012, OpenStreetMap Foundation
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

include_recipe "tools"
include_recipe "munin"

case node[:cpu][:"0"][:vendor_id]
when "GenuineIntel"
  package "intel-microcode"
end

case node[:cpu][:"0"][:vendor_id]
when "AuthenticAMD"
  if node[:lsb][:release].to_f >= 14.04
    package "amd64-microcode"
  end
end

if node[:dmi] && node[:dmi][:system]
  case node[:dmi][:system][:manufacturer]
  when "empty"
    manufacturer = node[:dmi][:base_board][:manufacturer]
    product = node[:dmi][:base_board][:product_name]
  else
    manufacturer = node[:dmi][:system][:manufacturer]
    product = node[:dmi][:system][:product_name]
  end
else
  manufacturer = "Unknown"
  product = "Unknown"
end

case manufacturer
when "HP"
  package "hponcfg"
  package "hp-health"
  unit = "1"
  speed = "115200"
when "TYAN"
  unit = "0"
  speed = "115200"
when "TYAN Computer Corporation"
  unit = "0"
  speed = "115200"
when "Supermicro"
  case product
  when "H8DGU", "X9SCD", "X7DBU", "X7DW3", "X9DR7/E-(J)LN4F", "X9DR3-F", "X9DRW"
    unit = "1"
    speed = "115200"
  else
    unit = "0"
    speed = "115200"
  end
when "IBM"
  unit = "0"
  speed = "115200"
end

if manufacturer == "HP" && node[:lsb][:release].to_f > 11.10
  include_recipe "git"

  git "/opt/hp/hp-legacy" do
    action :sync
    repository "git://chef.openstreetmap.org/hp-legacy.git"
    user "root"
    group "root"
    ignore_failure true
  end

  link "/opt/hp/hp-health/bin/hpasmd" do
    to "/opt/hp/hp-legacy/hpasmd"
  end

  link "/usr/lib/libhpasmintrfc.so.3.0" do
    to "/opt/hp/hp-legacy/libhpasmintrfc.so.3.0"
  end

  link "/usr/lib/libhpasmintrfc.so.3" do
    to "libhpasmintrfc.so.3.0"
  end

  link "/usr/lib/libhpasmintrfc.so" do
    to "libhpasmintrfc.so.3.0"
  end
end

unless unit.nil?
  file "/etc/init/ttySttyS#{unit}.conf" do
    action :delete
  end

  template "/etc/init/ttyS#{unit}.conf" do
    source "tty.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables :unit => unit, :speed => speed
  end

  service "ttyS#{unit}" do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => false
    subscribes :restart, "template[/etc/init/ttyS#{unit}.conf]"
  end
end

# if we need a different / special kernel version to make the hardware
# work (e.g: https://github.com/openstreetmap/operations/issues/45) then
# ensure that we have the package installed. the grub template will
# make sure that this is the default on boot.
if node[:hardware][:grub][:kernel]
  kernel_version = node[:hardware][:grub][:kernel]

  package "linux-image-#{kernel_version}-generic"
  package "linux-image-extra-#{kernel_version}-generic"
  package "linux-headers-#{kernel_version}-generic"

  boot_device = IO.popen(["df", "/boot"]).readlines.last.split.first
  boot_uuid = IO.popen(["blkid", "-o", "value", "-s", "UUID", boot_device]).readlines.first.chomp
  grub_entry = "gnulinux-advanced-#{boot_uuid}>gnulinux-#{kernel_version}-advanced-#{boot_uuid}"
else
  grub_entry = "0"
end

if File.exist?("/etc/default/grub")
  execute "update-grub" do
    action :nothing
    command "/usr/sbin/update-grub"
  end

  template "/etc/default/grub" do
    source "grub.erb"
    owner "root"
    group "root"
    mode 0644
    variables :unit => unit, :speed => speed, :entry => grub_entry
    notifies :run, "execute[update-grub]"
  end
end

execute "update-initramfs" do
  action :nothing
  command "update-initramfs -u -k all"
  user "root"
  group "root"
end

template "/etc/initramfs-tools/conf.d/mdadm" do
  source "initramfs-mdadm.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :run, "execute[update-initramfs]"
end

package "haveged"
service "haveged" do
  action [:enable, :start]
end

if node[:kernel][:modules].include?("ipmi_si")
  package "ipmitool"
end

if node[:lsb][:release].to_f >= 12.10
  package "irqbalance"

  template "/etc/default/irqbalance" do
    source "irqbalance.erb"
    owner "root"
    group "root"
    mode 0644
  end

  service "irqbalance" do
    action [:start, :enable]
    supports :status => false, :restart => true, :reload => false
    subscribes :restart, "template[/etc/default/irqbalance]"
  end
end

tools_packages = []
status_packages = {}

node[:kernel][:modules].each_key do |modname|
  case modname
  when "cciss"
    tools_packages << "hpssacli"
    status_packages["cciss-vol-status"] ||= []
  when "hpsa"
    tools_packages << "hpssacli"
    status_packages["cciss-vol-status"] ||= []
  when "mptsas"
    tools_packages << "lsiutil"
    # status_packages["mpt-status"] ||= []
  when "mpt2sas", "mpt3sas"
    tools_packages << "sas2ircu"
    status_packages["sas2ircu-status"] ||= []
  when "megaraid_mm"
    tools_packages << "megactl"
    status_packages["megaraid-status"] ||= []
  when "megaraid_sas"
    tools_packages << "megacli"
    status_packages["megaclisas-status"] ||= []
  when "aacraid"
    tools_packages << "arcconf"
    status_packages["aacraid-status"] ||= []
  when "arcmsr"
    tools_packages << "areca"
  end
end

node[:block_device].each do |name, attributes|
  next unless attributes[:vendor] == "HP" && attributes[:model] == "LOGICAL VOLUME"

  if name =~ /^cciss!(c[0-9]+)d[0-9]+$/
    status_packages["cciss-vol-status"] |= ["cciss/#{Regexp.last_match[1]}d0"]
  else
    Dir.glob("/sys/block/#{name}/device/scsi_generic/*").each do |sg|
      status_packages["cciss-vol-status"] |= [File.basename(sg)]
    end
  end
end

%w(hpacucli lsiutil sas2ircu megactl megacli arcconf).each do |tools_package|
  if tools_packages.include?(tools_package)
    package tools_package
  else
    package tools_package do
      action :purge
    end
  end
end

if tools_packages.include?("areca")
  include_recipe "git"

  git "/opt/areca" do
    action :sync
    repository "git://chef.openstreetmap.org/areca.git"
    user "root"
    group "root"
  end
else
  directory "/opt/areca" do
    action :delete
    recursive true
  end
end

["cciss-vol-status", "mpt-status", "sas2ircu-status", "megaraid-status", "megaclisas-status", "aacraid-status"].each do |status_package|
  if status_packages.include?(status_package)
    package status_package

    template "/etc/default/#{status_package}d" do
      source "raid.default.erb"
      owner "root"
      group "root"
      mode 0644
      variables :devices => status_packages[status_package]
    end

    service "#{status_package}d" do
      action [:start, :enable]
      supports :status => false, :restart => true, :reload => false
      subscribes :restart, "template[/etc/default/#{status_package}d]"
    end
  else
    package status_package do
      action :purge
    end

    file "/etc/default/#{status_package}d" do
      action :delete
    end
  end
end

disks = []

node[:block_device].each do |name, attributes|
  disks << { :device => name } if attributes[:vendor] == "ATA"
end

if status_packages["cciss-vol-status"] && File.exist?("/usr/sbin/cciss_vol_status")
  status_packages["cciss-vol-status"].each do |device|
    IO.popen(["cciss_vol_status", "-V", "/dev/#{device}"]).each do |line|
      disks << { :device => device, :driver => "cciss", :id => Regexp.last_match[1].to_i - 1 } if line =~ / bay ([0-9]+) +HP /
    end
  end
end

if status_packages["megaclisas-status"]
  controller = 0

  Dir.glob("/sys/class/scsi_host/host*") do |host|
    driver = File.new("#{host}/proc_name").read.chomp

    next unless driver == "megaraid_sas"

    bus = host.sub("/sys/class/scsi_host/host", "")
    device = File.basename(Dir.glob("/sys/bus/scsi/devices/#{bus}:*/scsi_generic/*").first)

    IO.popen(["megacli", "-PDList", "-a#{controller}", "-NoLog"]).each do |line|
      disks << { :device => device, :driver => "megaraid",  :id => Regexp.last_match[1] } if line =~ /^Device Id: ([0-9]+)$/

      disks.pop if line =~ /^Firmware state: Hotspare, Spun down$/
    end

    controller += 1
  end
end

if tools_packages.include?("lsiutil")
  Dir.glob("/sys/class/scsi_host/host*") do |host|
    driver = File.new("#{host}/proc_name").read.chomp

    next unless driver == "mptsas"

    bus = host.sub("/sys/class/scsi_host/host", "")

    Dir.glob("/sys/bus/scsi/devices/#{bus}:0:*/scsi_generic/*").each do |sg|
      disks << { :device => File.basename(sg) }
    end
  end
end

if status_packages["sas2ircu-status"]
  Dir.glob("/sys/class/scsi_host/host*") do |host|
    driver = File.new("#{host}/proc_name").read.chomp

    next unless driver == "mpt2sas" || driver == "mpt3sas"

    bus = host.sub("/sys/class/scsi_host/host", "")

    Dir.glob("/sys/bus/scsi/devices/#{bus}:0:*/scsi_generic/*").each do |sg|
      next if File.directory?("#{sg}/../../block")

      disks << { :device => File.basename(sg) }
    end
  end
end

if status_packages["aacraid-status"]
  Dir.glob("/sys/class/scsi_host/host*") do |host|
    driver = File.new("#{host}/proc_name").read.chomp

    next unless driver == "aacraid"

    bus = host.sub("/sys/class/scsi_host/host", "")

    Dir.glob("/sys/bus/scsi/devices/#{bus}:1:*/scsi_generic/*").each do |sg|
      disks << { :device => File.basename(sg) }
    end
  end
end

if tools_packages.include?("areca") && File.exist?("/opt/areca/x86_64/cli64")
  device = IO.popen(["lsscsi", "-g"]).grep(%r{Areca +RAID controller .*/dev/(sg[0-9]+)}) do
    Regexp.last_match[1]
  end.first

  IO.popen(["/opt/areca/x86_64/cli64", "disk", "info"]).each do |line|
    next if line =~ /N\.A\./

    if line =~ /^ +[0-9]+ +0*([0-9]+) +(?:Slot#|SLOT )0*([0-9]+) +/
      enc = Regexp.last_match[1]
      slot = Regexp.last_match[2]

      disks << { :device => device, :driver => "areca", :id => "#{slot}/#{enc}" }
    elsif line =~ /^ +([0-9]+) +[0-9]+ +/
      disks << { :device => device, :driver => "areca", :id => Regexp.last_match[1] }
    end
  end
end

disks.each do |disk|
  if disk[:device] =~ %r{^cciss/(.*)$}
    id = File.read("/sys/bus/cciss/devices/#{Regexp.last_match[1]}/unique_id").chomp

    disk[:munin] = "cciss-3#{id.downcase}"
  else
    disk[:munin] = disk[:device]
  end

  if disk[:id]
    disk[:munin] = "#{disk[:munin]}-#{disk[:id].to_s.tr('/', ':')}"
  end

  disk[:hddtemp] = disk[:munin].tr("-:", "_")
end

if disks.count > 0
  package "smartmontools"

  template "/usr/local/bin/smartd-mailer" do
    source "smartd-mailer.erb"
    owner "root"
    group "root"
    mode 0755
  end

  template "/etc/smartd.conf" do
    source "smartd.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables :disks => disks
    notifies :reload, "service[smartmontools]"
  end

  template "/etc/default/smartmontools" do
    source "smartmontools.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, "service[smartmontools]"
  end

  service "smartmontools" do
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
  end

  # Don't try and do munin monitoring of disks behind
  # an Areca controller as they only allow one thing to
  # talk to the controller at a time and smartd will
  # throw errors if it clashes with munin
  disks = disks.reject { |disk| disk[:driver] == "areca" }

  disks.each do |disk|
    munin_plugin "smart_#{disk[:munin]}" do
      target "smart_"
      conf "munin.smart.erb"
      conf_variables :disk => disk
    end
  end

  munin_plugin "hddtemp_smartctl" do
    conf "munin.hddtemp.erb"
    conf_variables :disks => disks
  end
else
  service "smartmontools" do
    action [:stop, :disable]
  end

  munin_plugin "hddtemp_smartctl" do
    action :delete
  end
end

plugins = Dir.glob("/etc/munin/plugins/smart_*").map { |p| File.basename(p) } -
          disks.map { |d| "smart_#{d[:munin]}" }

plugins.each do |plugin|
  munin_plugin plugin do
    action :delete
  end
end

if File.exist?("/etc/mdadm/mdadm.conf")
  mdadm_conf = edit_file "/etc/mdadm/mdadm.conf" do |line|
    line.gsub!(/^MAILADDR .*$/, "MAILADDR admins@openstreetmap.org")

    line
  end

  file "/etc/mdadm/mdadm.conf" do
    owner "root"
    group "root"
    mode 0644
    content mdadm_conf
  end

  service "mdadm" do
    action :nothing
    subscribes :restart, "file[/etc/mdadm/mdadm.conf]"
  end
end

template "/etc/modules" do
  source "modules.erb"
  owner "root"
  group "root"
  mode 0644
end

if node[:lsb][:release].to_f <= 12.10
  service "module-init-tools" do
    provider Chef::Provider::Service::Upstart
    action :nothing
    subscribes :start, "template[/etc/modules]"
  end
else
  service "kmod" do
    provider Chef::Provider::Service::Upstart
    action :nothing
    subscribes :start, "template[/etc/modules]"
  end
end

if node[:hardware][:watchdog]
  package "watchdog"

  template "/etc/default/watchdog" do
    source "watchdog.erb"
    owner "root"
    group "root"
    mode 0644
    variables :module => node[:hardware][:watchdog]
  end

  service "watchdog" do
    action [:enable, :start]
  end
end

unless Dir.glob("/sys/class/hwmon/hwmon*").empty?
  package "lm-sensors"

  Dir.glob("/sys/devices/platform/coretemp.*").each do |coretemp|
    cpu = File.basename(coretemp).sub("coretemp.", "").to_i
    chip = format("coretemp-isa-%04d", cpu)

    temps = Dir.glob("#{coretemp}/temp*_input").map do |temp|
      File.basename(temp).sub("temp", "").sub("_input", "").to_i
    end.sort

    if temps.first == 1
      node.default[:hardware][:sensors][chip][:temps][:temp1][:label] = "CPU #{cpu}"
      temps.shift
    end

    temps.each_with_index do |temp, index|
      node.default[:hardware][:sensors][chip][:temps]["temp#{temp}"][:label] = "CPU #{cpu} Core #{index}"
    end
  end

  execute "/etc/sensors.d/chef.conf" do
    action :nothing
    command "/usr/bin/sensors -s"
    user "root"
    group "root"
  end

  template "/etc/sensors.d/chef.conf" do
    source "sensors.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :run, "execute[/etc/sensors.d/chef.conf]"
  end
end
