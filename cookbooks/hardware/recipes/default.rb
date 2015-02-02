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

if node[:dmi] and node[:dmi][:system]
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

if manufacturer == "HP" and node[:lsb][:release].to_f > 11.10
  include_recipe "git"

  git "/opt/hp/hp-legacy" do
    action :sync
    repository "git://chef.openstreetmap.org/hp-legacy.git"
    user "root"
    group "root"
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
    action [ :enable, :start ]
    supports :status => true, :restart => true, :reload => false
    subscribes :restart, "template[/etc/init/ttyS#{unit}.conf]"
  end
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
    variables :unit => unit, :speed => speed
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
    action [ :start, :enable ]
    supports :status => false, :restart => true, :reload => false
    subscribes :restart, "template[/etc/default/irqbalance]"
  end
end

tools_packages = []
status_packages = {}

node[:kernel][:modules].each_key do |modname|
  case modname
  when "cciss"
    tools_packages << "hpacucli"
    status_packages["cciss-vol-status"] ||= []
  when "hpsa"
    tools_packages << "hpacucli"
    status_packages["cciss-vol-status"] ||= []
  when "mptsas"
    tools_packages << "lsiutil"
    #status_packages["mpt-status"] ||= []
  when "mpt2sas"
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
  end
end

node[:block_device].each do |name, attributes|
  if attributes[:vendor] == "HP" and attributes[:model] == "LOGICAL VOLUME"
    if name =~ /^cciss!(c[0-9]+)d[0-9]+$/
      status_packages["cciss-vol-status"] |= [ "cciss/#{$1}d0" ]
    else
      Dir.glob("/sys/block/#{name}/device/scsi_generic/*").each do |sg|
        status_packages["cciss-vol-status"] |= [ File.basename(sg) ]
      end
    end
  end
end

["hpacucli", "lsiutil", "sas2ircu", "megactl", "megacli", "arcconf"].each do |tools_package|
  if tools_packages.include?(tools_package)
    package tools_package
  else
    package tools_package do
      action :purge
    end
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
      action [ :start, :enable ]
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
    action [ :enable, :start ]
  end
end

unless Dir.glob("/sys/class/hwmon/hwmon*").empty?
  package "lm-sensors"

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
