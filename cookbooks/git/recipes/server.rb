#
# Cookbook Name:: git
# Recipe:: server
#
# Copyright 2011, OpenStreetMap Foundation
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

include_recipe "networking"
include_recipe "xinetd"

git_directory = node[:git][:directory]

directory git_directory do
  owner node[:git][:user]
  group node[:git][:group]
  mode 0o2775
end

if node[:git][:allowed_nodes]
  search(:node, node[:git][:allowed_nodes]).each do |n|
    n.interfaces(:role => :external).each do |interface|
      firewall_rule "accept-git" do
        action :accept
        family interface[:family]
        source "#{interface[:zone]}:#{interface[:address]}"
        dest "fw"
        proto "tcp:syn"
        dest_ports "git"
        source_ports "1024:"
      end
    end
  end
else
  firewall_rule "accept-git" do
    action :accept
    source "net"
    dest "fw"
    proto "tcp:syn"
    dest_ports "git"
    source_ports "1024:"
  end
end

Dir.new(git_directory).select { |name| name =~ /\.git$/ }.each do |repository|
  template "#{git_directory}/#{repository}/hooks/post-update" do
    source "post-update.erb"
    owner "root"
    group node[:git][:group]
    mode 0o755
  end

  next unless node[:recipes].include?("trac") && repository != "dns.git"

  template "#{git_directory}/#{repository}/hooks/post-receive" do
    source "post-receive.erb"
    owner "root"
    group node[:git][:group]
    mode 0o755
    variables :repository => "#{git_directory}/#{repository}"
  end
end

template "/etc/cron.daily/git-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0o755
end

template "/etc/xinetd.d/git" do
  source "xinetd.erb"
  owner "root"
  group "root"
  mode 0o644
  notifies :reload, "service[xinetd]"
end
