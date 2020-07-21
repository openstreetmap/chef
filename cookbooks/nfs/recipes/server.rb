#
# Cookbook:: nfs
# Recipe:: server
#
# Copyright:: 2010, OpenStreetMap Foundation
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

package "nfs-kernel-server"

service "rpcbind" do
  action [:enable, :start]
end

service "nfs-server" do
  action [:enable, :start]
end

exports = {}

search(:node, "*:*") do |client|
  next unless client[:nfs]

  client[:nfs].each_value do |mount|
    next unless mount[:host] == node[:hostname]

    client.ipaddresses do |address|
      exports[mount[:path]] ||= {}

      exports[mount[:path]][address] = if mount[:readonly]
                                         "ro"
                                       else
                                         "rw"
                                       end
    end
  end
end

execute "exportfs" do
  action :nothing
  command "/usr/sbin/exportfs -ra"
end

template "/etc/exports" do
  source "exports.erb"
  owner "root"
  group "root"
  mode "644"
  variables :exports => exports
  notifies :run, "execute[exportfs]"
end
