#
# Cookbook Name:: nginx
# Definition:: nginx_site
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

define :nginx_site, :action => [ :create ], :variables => {} do
  name = params[:name]
  directory = params[:directory] || "/var/www/#{name}"
  site_action = params[:action]

  if site_action.include?(:create)
    template "/etc/nginx/conf.d/#{name}.conf" do
      cookbook params[:cookbook]
      source params[:template]
      owner "root"
      group "root"
      mode 0644
      variables params[:variables].merge(:name => name, :directory => directory)
      notifies :reload, "service[nginx]"
    end
  elsif site_action.include?(:delete)
    file "/etc/nginx/conf.d/#{name}.conf" do
      action :delete
      notifies :restart, "service[nginx]"
    end
  end
end
