#
# Cookbook:: clamav
# Recipe:: default
#
# Copyright:: 2011, OpenStreetMap Foundation
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

include_recipe "accounts"

package %w[
  clamav-daemon
  clamav-freshclam
]

if platform?("debian") && node[:platform_version].to_i >= 13
  package "clamav-unofficial-sigs" do
    action :remove
  end

  package %w[
    fangfrisch
    clamdscan
  ]

  directory "/var/lib/fangfrisch" do
    owner "clamav"
    group "clamav"
    mode "775"
  end

  template "/etc/fangfrisch.conf" do
    source "fangfrisch.conf.erb"
    owner "root"
    group "root"
    mode "644"
  end

  execute "fangfrisch-initdb" do
    command "/usr/bin/fangfrisch --conf /etc/fangfrisch.conf initdb"
    user "clamav"
    group "clamav"
    not_if do
      ::File.exist?("/var/lib/fangfrisch/db.sqlite")
    end
  end

  service "fangfrisch.timer" do
    action [:enable, :start]
  end

  file "/etc/clamav-unofficial-sigs.conf.d/50-chef.conf" do
    action :delete
  end
else
  package "clamav-unofficial-sigs"

  template "/etc/clamav-unofficial-sigs.conf.d/50-chef.conf" do
    source "clamav-unofficial-sigs.conf.erb"
    owner "root"
    group "root"
    mode "644"
  end
end

execute "freshclam" do
  command "/usr/bin/freshclam"
  user "clamav"
  group "clamav"
  not_if do
    ::File.exist?("/var/lib/clamav/daily.cld") ||
      ::File.exist?("/var/lib/clamav/daily.cvd")
  end
end

service "clamav-daemon" do
  action [:enable, :start]
  supports :status => true, :restart => true
end

service "clamav-freshclam" do
  action [:enable, :start]
  supports :status => true, :restart => true
end
