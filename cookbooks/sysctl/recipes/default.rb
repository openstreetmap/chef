#
# Cookbook Name:: sysctl
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

package "procps" do
  action :install
end

directory "/etc/sysctl.d" do
  owner "root"
  group "root"
  mode 0755
end

execute "sysctl" do
  action :nothing
  command "/sbin/sysctl -p /etc/sysctl.d/60-chef.conf"
end

template "/etc/sysctl.d/60-chef.conf" do
  source "chef.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :run, "execute[sysctl]"
end

node[:sysctl].each_value do |group|
  group[:parameters].each do |key,value|
    sysctl_file = "/proc/sys/#{key.gsub('.', '/')}"

    file sysctl_file do
      content "#{value}\n"
      atomic_update false
      only_if { File.exist?(sysctl_file) }
    end
  end
end
