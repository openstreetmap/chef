#
# Cookbook Name:: networking
# Definition:: fail2ban_jail
#
# Copyright 2013, OpenStreetMap Foundation
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

define :fail2ban_jail, :action => :create do
  template "/etc/fail2ban/jail.d/50-#{params[:name]}.conf" do
    source "jail.erb"
    owner "root"
    group "root"
    mode 0644
    variables params
    if node[:lsb][:release].to_f >= 14.04
      notifies :create, "template[/etc/fail2ban/jail.local]"
    else
      notifies :reload, "service[fail2ban]"
    end
  end
end
