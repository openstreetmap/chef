#
# Cookbook:: atlas
# Recipe:: default
#
# Copyright:: 2025, OpenStreetMap Foundation
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

include_recipe "apt::ripe-atlas"

package "ripe-atlas-probe" do
  action :install
end

template "/etc/ripe-atlas/config.txt" do
  source "ripe-config.txt.erb"
  owner "root"
  group "root"
  mode "644"
  variables :http_post_port => 58080
end

service "ripe-atlas" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/ripe-atlas/config.txt]"
end
