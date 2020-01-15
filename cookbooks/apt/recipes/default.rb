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
  update-notifier-common
]

file "/etc/motd.tail" do
  action :delete
end

template "/etc/apt/preferences.d/99-chef" do
  source "preferences.erb"
  owner "root"
  group "root"
  mode 0o644
end

apt_update "/etc/apt/sources.list" do
  action :nothing
end

archive_host = if node[:country]
                 "#{node[:country]}.archive.ubuntu.com"
               else
                 "archive.ubuntu.com"
               end

template "/etc/apt/sources.list" do
  source "sources.list.erb"
  owner "root"
  group "root"
  mode 0o644
  variables :archive_host => archive_host, :codename => node[:lsb][:codename]
  notifies :update, "apt_update[/etc/apt/sources.list]", :immediately
end

repository_actions = Hash.new do |_, repository|
  node[:apt][:sources].include?(repository) ? :add : :remove
end

apt_repository "brightbox-ruby-ng" do
  action repository_actions["brightbox-ruby-ng"]
  uri "ppa:brightbox/ruby-ng"
end

apt_repository "ubuntugis-stable" do
  action repository_actions["ubuntugis-stable"]
  uri "ppa:ubuntugis/ppa"
end

apt_repository "ubuntugis-unstable" do
  action repository_actions["ubuntugis-unstable"]
  uri "ppa:ubuntugis/ubuntugis-unstable"
end

apt_repository "maxmind" do
  action repository_actions["maxmind"]
  uri "ppa:maxmind/ppa"
end

apt_repository "openstreetmap" do
  action repository_actions["openstreetmap"]
  uri "ppa:osmadmins/ppa"
end

apt_repository "squid2" do
  action repository_actions["squid2"]
  uri "ppa:osmadmins/squid2"
end

apt_repository "squid3" do
  action repository_actions["squid3"]
  uri "ppa:osmadmins/squid3"
end

apt_repository "squid4" do
  action repository_actions["squid4"]
  uri "ppa:osmadmins/squid4"
end

apt_repository "management-component-pack" do
  action repository_actions["management-component-pack"]
  uri "https://downloads.linux.hpe.com/SDR/repo/mcp"
  distribution "#{node[:lsb][:codename]}/current-gen9"
  components ["non-free"]
  key "C208ADDE26C2B797"
end

apt_repository "hwraid" do
  action repository_actions["hwraid"]
  uri "https://hwraid.le-vert.net/ubuntu"
  distribution "precise"
  components ["main"]
  key "6005210E23B3D3B4"
end

apt_repository "nginx" do
  action repository_actions["nginx"]
  arch "amd64"
  uri "https://nginx.org/packages/ubuntu"
  components ["nginx"]
  key "ABF5BD827BD9BF62"
end

apt_repository "elasticsearch5.x" do
  action repository_actions["elasticsearch5.x"]
  uri "https://artifacts.elastic.co/packages/5.x/apt"
  distribution "stable"
  components ["main"]
  key "D27D666CD88E42B4"
end

apt_repository "elasticsearch6.x" do
  action repository_actions["elasticsearch6.x"]
  uri "https://artifacts.elastic.co/packages/6.x/apt"
  distribution "stable"
  components ["main"]
  key "D27D666CD88E42B4"
end

apt_repository "passenger" do
  action repository_actions["passenger"]
  uri "https://oss-binaries.phusionpassenger.com/apt/passenger"
  components ["main"]
  key "561F9B9CAC40B2F7"
end

apt_repository "postgresql" do
  action repository_actions["postgresql"]
  uri "https://apt.postgresql.org/pub/repos/apt"
  distribution "#{node[:lsb][:codename]}-pgdg"
  components ["main"]
  key "7FCC7D46ACCC4CF8"
end

apt_repository "mediawiki" do
  action repository_actions["mediawiki"]
  uri "https://releases.wikimedia.org/debian"
  distribution "jessie-mediawiki"
  components ["main"]
  key "AF380A3036A03444"
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
    mode 0o644
    content auto_upgrades
  end
end

template "/etc/apt/apt.conf.d/60chef" do
  source "apt.conf.erb"
  owner "root"
  group "root"
  mode 0o644
end
