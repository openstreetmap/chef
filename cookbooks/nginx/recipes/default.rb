#
# Cookbook:: nginx
# Recipe:: default
#
# Copyright:: 2013, OpenStreetMap Foundation
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

include_recipe "apt::nginx"
include_recipe "prometheus"
include_recipe "ssl"

package "nginx"

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

directory node[:nginx][:cache][:fastcgi][:directory] do
  owner "www-data"
  group "root"
  mode "755"
  recursive true
  only_if { node[:nginx][:cache][:fastcgi][:enable] }
end

directory node[:nginx][:cache][:proxy][:directory] do
  owner "www-data"
  group "root"
  mode "755"
  recursive true
  only_if { node[:nginx][:cache][:proxy][:enable] }
end

service "nginx" do
  action [:enable] # Do not start the service as config may be broken from failed chef run
  supports :status => true, :restart => true, :reload => true
  subscribes :restart, "template[/etc/nginx/nginx.conf]"
end

prometheus_exporter "nginx" do
  port 9113
  options "--nginx.scrape-uri=http://localhost:8050/nginx_status"
end
