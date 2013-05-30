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

if node[:lsb][:release].to_f <= 8.04
  sysctl_template = "sysctl.conf.erb"
  sysctl_conf = "/etc/sysctl.conf"
else
  directory "/etc/sysctl.d" do
    owner "root"
    group "root"
    mode 0755
  end

  sysctl_template = "chef.conf.erb"
  sysctl_conf = "/etc/sysctl.d/60-chef.conf"
end

execute "sysctl" do
  action :nothing
  command "/sbin/sysctl -p #{sysctl_conf}"
end

template sysctl_conf do
  source sysctl_template
  owner "root"
  group "root"
  mode 0644
  notifies :run, resources(:execute => "sysctl")
end

node[:sysctl].each_value do |group|
  group[:parameters].each do |key,value|
    sysctl_file = "/proc/sys/#{key.gsub('.', '/')}"

    file sysctl_file do
      content "#{value}\n"
      only_if { File.exists?(sysctl_file) }
    end
  end
end
