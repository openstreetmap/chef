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

# FIXME: cleanup old package pin method for cciss-vol-status
file "/etc/apt/preferences.d/99-chef" do
  action :delete
end

apt_preference "cciss-vol-status" do
  pin          "origin *.ubuntu.com"
  pin_priority "1100"
end

apt_update "/etc/apt/sources.list" do
  action :nothing
end

if platform?("debian")
  archive_host = "deb.debian.org"
  archive_security_host = archive_host
  archive_distro = "debian"
  archive_security_distro = "debian-security"
  archive_suites = %w[main updates security]
  archive_components = %w[main contrib non-free]
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
else
  archive_host = "ports.ubuntu.com"
  archive_security_host = archive_host
  archive_distro = "ubuntu-ports"
  archive_security_distro = archive_distro
  archive_suites = %w[main updates backports security]
  archive_components = %w[main restricted universe multiverse]
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

apt_repository "openstreetmap" do
  uri "ppa:osmadmins/ppa"
  only_if { platform?("ubuntu") }
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
