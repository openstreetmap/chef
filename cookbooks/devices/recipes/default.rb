#
# Cookbook:: devices
# Recipe:: default
#
# Copyright:: 2012, OpenStreetMap Foundation
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

cookbook_file "/usr/local/bin/fixeep-82574_83.sh" do
  owner "root"
  group "root"
  mode "755"
end

execute "udevadm-trigger" do
  action :nothing
  command "/bin/udevadm trigger --action=add"
end

template "/etc/udev/rules.d/99-chef.rules" do
  source "udev.rules.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :run, "execute[udevadm-trigger]"
end
