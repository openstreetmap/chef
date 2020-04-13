#
# Cookbook:: sysctl
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

file "/etc/sysctl.d/60-chef.conf" do
  action :delete
end

if node[:virtualization][:role] != "guest" ||
   (node[:virtualization][:system] != "lxc" &&
    node[:virtualization][:system] != "lxd" &&
    node[:virtualization][:system] != "openvz")
  keys = []

  Dir.new("/etc/sysctl.d").each_entry do |file|
    next unless file =~ /^99-chef-(.*)\.conf$/

    keys.push(Regexp.last_match(1))
  end

  node[:sysctl].each_value do |group|
    group[:parameters].each do |key, value|
      sysctl key do
        value value
        # comment group[:comment]
      end

      keys.delete(key)
    end
  end

  keys.each do |key|
    sysctl key do
      action :remove
    end
  end
end
