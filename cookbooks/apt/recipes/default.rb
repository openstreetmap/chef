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
package "update-notifier-common"
package "debconf-utils"

file "/etc/motd.tail" do
  action :delete
end

execute "apt-update" do
  action :nothing
  command "/usr/bin/apt-get update"
end

template "/etc/apt/sources.list" do
  source "sources.list.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :run, "execute[apt-update]", :immediately
end

apt_source "brightbox-ruby-ng" do
  url "http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu"
  key "C3173AA6"
end

apt_source "ubuntugis-stable" do
  url "http://ppa.launchpad.net/ubuntugis/ppa/ubuntu"
  key "314DF160"
end

apt_source "ubuntugis-unstable" do
  url "http://ppa.launchpad.net/ubuntugis/ubuntugis-unstable/ubuntu"
  key "314DF160"
end

apt_source "openstreetmap" do
  template "openstreetmap.list.erb"
  url "http://ppa.launchpad.net/osmadmins/ppa/ubuntu"
  key "0AC4F2CB"
end

apt_source "management-component-pack" do
  template "hp.list.erb"
  url "http://downloads.linux.hp.com/SDR/downloads/ManagementComponentPack"
  key "B1275EA3"
end

apt_source "hwraid" do
  template "hwraid.list.erb"
  url "http://hwraid.le-vert.net/ubuntu"
  key "23B3D3B4"
end

apt_source "mapnik-v210" do
  url "http://ppa.launchpad.net/mapnik/v2.1.0/ubuntu"
  key "5D50B6BA"
end

apt_source "nginx" do
  template "nginx.list.erb"
  url "http://nginx.org/packages/ubuntu"
  key "7BD9BF62"
end

apt_source "elasticsearch" do
  template "elasticsearch.list.erb"
  url "http://packages.elasticsearch.org/elasticsearch/1.7/debian"
  key "D88E42B4"
end

apt_source "logstash" do
  template "elasticsearch.list.erb"
  url "http://packages.elasticsearch.org/logstash/1.5/debian"
  key "D88E42B4"
end

apt_source "logstash-forwarder" do
  template "elasticsearch.list.erb"
  url "http://packages.elasticsearch.org/logstashforwarder/debian"
  key "D88E42B4"
end

apt_source "passenger" do
  url "https://oss-binaries.phusionpassenger.com/apt/passenger"
  key "AC40B2F7"
end

apt_source "postgresql" do
  template "postgresql.list.erb"
  url "http://apt.postgresql.org/pub/repos/apt"
  key "ACCC4CF8"
end

package "unattended-upgrades" do
  response_file "unattended-upgrades.seed.erb"
  action :install
end

# Not idempotent - reconfig runs every time, required if package previously installed without response_file or response_file changes
package "unattended-upgrades_reconfig" do
  package_name "unattended-upgrades"
  response_file "unattended-upgrades.seed.erb"
  action :reconfig
end

template "/etc/apt/apt.conf.d/60chef" do
  source "apt.conf.erb"
  owner "root"
  group "root"
  mode 0644
end
