#
# Cookbook Name:: squid
# Definition:: squid_fragment
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

define :squid_fragment, :action => [:create], :variables => {} do
  name = params[:name]
  site_action = params[:action]

  if site_action.include?(:create)
    template "/etc/squid/squid.conf.d/#{name}.conf" do
      source params[:template]
      owner "root"
      group "root"
      mode 0644
      variables params[:variables]
      notifies :create, "template[/etc/squid/squid.conf]"
    end
  elsif site_action.include?(:delete)
    template "/etc/squid/squid.conf.d/#{name}.conf" do
      action :delete
      notifies :create, "template[/etc/squid/squid.conf]"
    end
  end
end
