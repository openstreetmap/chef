#
# Cookbook Name:: fail2ban
# Provider:: fail2ban_jail
#
# Copyright 2015, OpenStreetMap Foundation
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

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  template "/etc/fail2ban/jail.d/50-#{new_resource.name}.conf" do
    cookbook "fail2ban"
    source "jail.erb"
    owner "root"
    group "root"
    mode 0644
    variables :name => new_resource.name,
              :filter => new_resource.filter,
              :logpath => new_resource.logpath,
              :protocol => new_resource.protocol,
              :ports => new_resource.ports,
              :maxretry => new_resource.maxretry
  end
end

action :delete do
  file "/etc/fail2ban/jail.d/50-#{new_resource.name}.conf" do
    action :delete
  end
end
