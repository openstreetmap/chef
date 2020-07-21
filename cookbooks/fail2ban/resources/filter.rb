#
# Cookbook:: fail2ban
# Resource:: fail2ban_filter
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

property :filter, :kind_of => String, :name_property => true
property :source, :kind_of => String
property :failregex, :kind_of => [String, Array]
property :ignoreregex, :kind_of => [String, Array]

action :create do
  if new_resource.source
    remote_file "/etc/fail2ban/filter.d/#{new_resource.filter}.conf" do
      source new_resource.source
      owner "root"
      group "root"
      mode "644"
    end
  else
    template "/etc/fail2ban/filter.d/#{new_resource.filter}.conf" do
      cookbook "fail2ban"
      source "filter.erb"
      owner "root"
      group "root"
      mode "644"
      variables :failregex => new_resource.failregex,
                :ignoreregex => new_resource.ignoreregex
    end
  end
end

action :delete do
  file "/etc/fail2ban/filter.d/#{new_resource.filter}.conf" do
    action :delete
  end
end

def after_created
  notifies :restart, "service[fail2ban]"
end
