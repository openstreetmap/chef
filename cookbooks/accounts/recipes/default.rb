#
# Cookbook:: accounts
# Recipe:: default
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

package "zsh"

administrators = []

search(:accounts, "*:*").each do |account|
  name = account["id"]
  details = node[:accounts][:users][name] || {}

  if details[:status]
    group_members = details[:members] || account["members"] || []
    user_home = details[:home] || account["home"] || "#{node[:accounts][:home]}/#{name}"
    manage_user_home = details.fetch(:manage_home, account.fetch("manage_home", node[:accounts][:manage_home]))

    group_members = group_members.collect(&:to_s).sort

    case details[:status]
    when "role"
      user_shell = "/usr/sbin/nologin"
    when "user", "administrator"
      user_shell = details[:shell] || account["shell"] || node[:accounts][:shell]
    end

    group name.to_s do
      gid account["uid"].to_i
      members group_members & node[:etc][:passwd].keys
    end

    user name.to_s do
      uid account["uid"].to_i
      gid account["uid"].to_i
      comment account["comment"] if account["comment"]
      home user_home
      shell user_shell
      manage_home manage_user_home
    end

    remote_directory "/home/#{name}" do
      path user_home
      source name.to_s
      owner name.to_s
      group name.to_s
      mode 0o755
      files_owner name.to_s
      files_group name.to_s
      files_mode 0o644
      only_if do
        begin
          cookbook = run_context.cookbook_collection[cookbook_name]
          files = cookbook.relative_filenames_in_preferred_directory(node, :files, name.to_s)
          !files.empty?
        rescue Chef::Exceptions::FileNotFound
          false
        end
      end
    end

    administrators.push(name.to_s) if details[:status] == "administrator"
  else
    user name.to_s do
      action :remove
    end

    group name.to_s do
      action :remove
    end
  end
end

node[:accounts][:groups].each do |name, details|
  group name do
    action :modify
    members details[:members]
    append true
  end
end

group "sudo" do
  action :manage
  members administrators.sort
end

group "admin" do
  action :manage
  members administrators.sort
end

group "adm" do
  action :modify
  members administrators.sort
end
