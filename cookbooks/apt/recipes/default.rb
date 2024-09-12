#
# Cookbook:: apt
# Recipe:: default
#
# Copyright:: 2010, Tom Hughes
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

package %w[
  apt
  apt-transport-https
  gnupg
]

package "update-notifier-common" if platform?("ubuntu")

file "/etc/motd.tail" do
  action :delete
end

apt_preference "cciss-vol-status" do
  pin          "origin *.ubuntu.com"
  pin_priority "1100"
end

apt_update "/etc/apt/sources.list" do
  action :nothing
end

dpkg_arch = node[:packages][:systemd][:arch]

if platform?("debian")
  archive_host = "deb.debian.org"
  archive_security_host = archive_host
  archive_distro = "debian"
  archive_security_distro = "debian-security"
  archive_suites = %w[main updates backports security]
  archive_components = %w[main contrib non-free non-free-firmware]
  backport_packages = case node[:lsb][:codename]
                      when "bookworm" then %W[amd64-microcode exim4 firmware-free firmware-nonfree intel-microcode libosmium linux-signed-#{dpkg_arch} osm2pgsql otrs2 pyosmium smartmontools systemd]
                      else %W[]
                      end
elsif intel?
  archive_host = if node[:country]
                   "#{node[:country]}.archive.ubuntu.com"
                 else
                   "archive.ubuntu.com"
                 end
  archive_security_host = "security.ubuntu.com"
  archive_distro = "ubuntu"
  archive_security_distro = archive_distro
  archive_suites = %w[main updates backports security]
  archive_components = %w[main restricted universe multiverse]
  backport_packages = %w[]
else
  archive_host = "ports.ubuntu.com"
  archive_security_host = archive_host
  archive_distro = "ubuntu-ports"
  archive_security_distro = archive_distro
  archive_suites = %w[main updates backports security]
  archive_components = %w[main restricted universe multiverse]
  backport_packages = %w[]
end

template "/etc/apt/sources.list" do
  source "sources.list.erb"
  owner "root"
  group "root"
  mode "644"
  variables :archive_host => archive_host,
            :archive_security_host => archive_security_host,
            :archive_distro => archive_distro,
            :archive_security_distro => archive_security_distro,
            :archive_suites => archive_suites,
            :archive_components => archive_components,
            :codename => node[:lsb][:codename]
  notifies :update, "apt_update[/etc/apt/sources.list]", :immediately
end

if backport_packages.empty?
  apt_preference "backports" do
    action :remove
  end
else
  apt_preference "backports" do
    glob backport_packages.sort.map { |p| "src:#{p}" }.join(" ")
    pin "release n=#{node[:lsb][:codename]}-backports"
    pin_priority "500"
  end
end

execute "apt-cache-gencaches" do
  action :nothing
  command "apt-cache gencaches"
  subscribes :run, "apt_preference[backports]", :immediately
end

apt_repository "openstreetmap" do
  uri "https://apt.openstreetmap.org"
  components ["main"]
  key "https://apt.openstreetmap.org/gpg.key"
end

package "unattended-upgrades"

if Dir.exist?("/usr/share/unattended-upgrades")
  auto_upgrades = if node[:apt][:unattended_upgrades][:enable]
                    IO.read("/usr/share/unattended-upgrades/20auto-upgrades")
                  else
                    IO.read("/usr/share/unattended-upgrades/20auto-upgrades-disabled")
                  end

  file "/etc/apt/apt.conf.d/20auto-upgrades" do
    user "root"
    group "root"
    mode "644"
    content auto_upgrades
  end
end

template "/etc/apt/apt.conf.d/60chef" do
  source "apt.conf.erb"
  owner "root"
  group "root"
  mode "644"
end
