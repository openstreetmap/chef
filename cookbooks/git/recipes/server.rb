#
# Cookbook:: git
# Recipe:: server
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

node.default[:accounts][:users][:git][:status] = :role

include_recipe "accounts"
include_recipe "apt"
include_recipe "networking"

git_directory = node[:git][:directory]

directory git_directory do
  owner "root"
  group "root"
  mode "775"
end

directory "#{git_directory}/public" do
  owner node[:git][:public_user]
  group node[:git][:public_group]
  mode "2775"
end

directory "#{git_directory}/private" do
  owner node[:git][:private_user]
  group node[:git][:private_group]
  mode "2775"
end

Dir.glob("#{git_directory}/*/*.git").each do |repository|
  template "#{repository}/hooks/post-update" do
    source "post-update.erb"
    owner "root"
    group node[:git][:group]
    mode "755"
  end
end

template "/etc/cron.daily/git-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode "755"
end
