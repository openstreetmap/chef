#
# Cookbook:: elasticsearch
# Recipe:: default
#
# Copyright:: 2014, OpenStreetMap Foundation
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

include_recipe "prometheus"

case node[:elasticsearch][:version]
when "6.x" then include_recipe "apt::elasticsearch6"
when "7.x" then include_recipe "apt::elasticsearch7"
when "8.x" then include_recipe "apt::elasticsearch8"
end

package "default-jre-headless"
package "elasticsearch"

template "/etc/elasticsearch/elasticsearch.yml" do
  source "elasticsearch.yml.erb"
  user "root"
  group "root"
  mode "644"
  notifies :restart, "service[elasticsearch]"
end

service "elasticsearch" do
  action [:enable, :start]
  supports :status => true, :restart => true
end

prometheus_exporter "elasticsearch" do
  port 9114
end
