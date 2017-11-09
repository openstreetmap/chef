#
# Cookbook Name:: apt
# Recipe:: default
#
# Copyright 2010, Tom Hughes
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

package "apt"
package "gnupg-curl"
package "update-notifier-common"

file "/etc/motd.tail" do
  action :delete
end

execute "apt-update" do
  action :nothing
  command "/usr/bin/apt-get update"
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
  notifies :run, "execute[apt-update]", :immediately
end

if node[:lsb][:release].to_f >= 16.04
  apt_source "brightbox-ruby-ng" do
    action :delete
  end
else
  apt_source "brightbox-ruby-ng" do
    url "http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu"
    key "F5DA5F09C3173AA6"
  end
end

apt_source "ubuntugis-stable" do
  url "http://ppa.launchpad.net/ubuntugis/ppa/ubuntu"
  key "089EBE08314DF160"
end

apt_source "ubuntugis-unstable" do
  url "http://ppa.launchpad.net/ubuntugis/ubuntugis-unstable/ubuntu"
  key "089EBE08314DF160"
end

apt_source "openstreetmap" do
  url "http://ppa.launchpad.net/osmadmins/ppa/ubuntu"
  key "D57F48750AC4F2CB"
  update true
end

apt_source "management-component-pack" do
  source_template "hp.list.erb"
  url "http://downloads.linux.hpe.com/SDR/repo/mcp"
  key "C208ADDE26C2B797"
  key_url "https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub"
end

apt_source "hwraid" do
  source_template "hwraid.list.erb"
  url "http://hwraid.le-vert.net/ubuntu"
  key "6005210E23B3D3B4"
end

apt_source "mapnik-v210" do
  url "http://ppa.launchpad.net/mapnik/v2.1.0/ubuntu"
  key "4F7B93595D50B6BA"
end

apt_source "nginx" do
  source_template "nginx.list.erb"
  url "http://nginx.org/packages/ubuntu"
  key "ABF5BD827BD9BF62"
end

apt_source "elasticsearch1.7" do
  source_template "elasticsearch.list.erb"
  url "http://packages.elasticsearch.org/elasticsearch/1.7/debian"
  key "D27D666CD88E42B4"
end

apt_source "elasticsearch2.x" do
  source_template "elasticsearch.list.erb"
  url "http://packages.elasticsearch.org/elasticsearch/2.x/debian"
  key "D27D666CD88E42B4"
end

apt_source "elasticsearch5.x" do
  source_template "elasticsearch.list.erb"
  url "https://artifacts.elastic.co/packages/5.x/apt"
  key "D27D666CD88E42B4"
end

apt_source "logstash" do
  source_template "elasticsearch.list.erb"
  url "http://packages.elasticsearch.org/logstash/2.3/debian"
  key "D27D666CD88E42B4"
end

apt_source "logstash-forwarder" do
  source_template "elasticsearch.list.erb"
  url "http://packages.elasticsearch.org/logstashforwarder/debian"
  key "D27D666CD88E42B4"
end

apt_source "passenger" do
  url "https://oss-binaries.phusionpassenger.com/apt/passenger"
  key "561F9B9CAC40B2F7"
end

apt_source "postgresql" do
  source_template "postgresql.list.erb"
  url "http://apt.postgresql.org/pub/repos/apt"
  key "7FCC7D46ACCC4CF8"
end

apt_source "mediawiki" do
  source_template "mediawiki.list.erb"
  url "https://releases.wikimedia.org/debian"
  key "90E9F83F22250DD7"
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
