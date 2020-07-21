#
# Cookbook:: incron
# Recipe:: default
#
# Copyright:: 2014, OpenStreetMap Foundation
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

package "incron"

service "incron" do
  action [:enable, :start]
  supports :status => true, :reload => true, :restart => true
end

incrontabs = {}

node[:incron].each_value do |details|
  user = details[:user]
  path = details[:path]
  mask = details[:events].join(",")
  command = details[:command]

  incrontabs[user] ||= []

  incrontabs[user].push("#{path} #{mask} #{command}")
end

incrontabs.each do |user, lines|
  file "/var/spool/incron/#{user}" do
    owner user
    group "incron"
    mode "600"
    content lines.join("\n")
  end
end

file "/etc/incron.allow" do
  owner "root"
  group "incron"
  mode "0640"
  content incrontabs.keys.sort.join("\n")
end
