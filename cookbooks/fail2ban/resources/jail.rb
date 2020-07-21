#
# Cookbook:: fail2ban
# Resource:: fail2ban_jail
#
# Copyright:: 2015, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :create

property :jail, :kind_of => String, :name_property => true
property :filter, :kind_of => String
property :logpath, :kind_of => String
property :protocol, :kind_of => String
property :ports, :kind_of => Array, :default => []
property :maxretry, :kind_of => Integer
property :ignoreips, :kind_of => Array

action :create do
  template "/etc/fail2ban/jail.d/50-#{new_resource.jail}.conf" do
    cookbook "fail2ban"
    source "jail.erb"
    owner "root"
    group "root"
    mode "644"
    variables :name => new_resource.jail,
              :filter => new_resource.filter,
              :logpath => new_resource.logpath,
              :protocol => new_resource.protocol,
              :ports => new_resource.ports,
              :maxretry => new_resource.maxretry,
              :ignoreips => new_resource.ignoreips
  end
end

action :delete do
  file "/etc/fail2ban/jail.d/50-#{new_resource.jail}.conf" do
    action :delete
  end
end

def after_created
  notifies :restart, "service[fail2ban]"
end
