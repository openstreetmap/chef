#
# Cookbook Name:: ntp
# Recipe:: default
#
# Copyright 2010, OpenStreetMap Foundation.
# Copyright 2009, Opscode, Inc
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

package %w[
  chrony
  tzdata
]

execute "dpkg-reconfigure-tzdata" do
  action :nothing
  command "/usr/sbin/dpkg-reconfigure -f noninteractive tzdata"
  user "root"
  group "root"
end

link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{node[:ntp][:tz]}"
  owner "root"
  group "root"
  notifies :run, "execute[dpkg-reconfigure-tzdata]", :immediately
end

template "/etc/chrony/chrony.conf" do
  source "chrony.conf.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :restart, "service[chrony]"
end

service "chrony" do
  action [:enable, :start]
end

munin_plugin "chrony"
