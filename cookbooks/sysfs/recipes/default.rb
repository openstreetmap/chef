#
# Cookbook:: sysfs
# Recipe:: default
#
# Copyright:: 2013, Tom Hughes
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

if node[:virtualization][:role] == "guest" &&
   node[:virtualization][:system] == "lxd"
  package "sysfsutils" do
    action :purge
  end
else
  package "sysfsutils"

  service "sysfsutils" do
    action :enable
    supports :status => false, :restart => true, :reload => false
  end

  template "/etc/sysfs.d/99-chef.conf" do
    source "sysfs.conf.erb"
    owner "root"
    group "root"
    mode "644"
    notifies :restart, "service[sysfsutils]"
  end

  node[:sysfs].each_value do |group|
    group[:parameters].each do |key, value|
      sysfs_file = "/sys/#{key}"

      file sysfs_file do
        content "#{value}\n"
        atomic_update false
        ignore_failure true
      end
    end
  end
end
