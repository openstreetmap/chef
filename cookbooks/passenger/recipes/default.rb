#
# Cookbook:: passenger
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

include_recipe "apache"
include_recipe "apt"
include_recipe "munin"
include_recipe "prometheus"

package "ruby#{node[:passenger][:ruby_version]}"
package "ruby#{node[:passenger][:ruby_version]}-dev"

if node[:passenger][:ruby_version].to_f < 1.9
  package "rubygems#{node[:passenger][:ruby_version]}"
  package "irb#{node[:passenger][:ruby_version]}"
end

template "/usr/local/bin/passenger-ruby" do
  source "ruby.erb"
  owner "root"
  group "root"
  mode "755"
  notifies :reload, "service[apache2]"
end

systemd_tmpfile node[:passenger][:instance_registry_dir] do
  type "d"
  owner "root"
  group "root"
  mode "0755"
end

apache_module "passenger" do
  conf "passenger.conf.erb"
end

munin_plugin_conf "passenger" do
  template "munin.erb"
end

munin_plugin "passenger_memory"
munin_plugin "passenger_processes"
munin_plugin "passenger_queues"
munin_plugin "passenger_requests"

prometheus_exporter "passenger" do
  port 9149
  environment "PASSENGER_INSTANCE_REGISTRY_DIR" => node[:passenger][:instance_registry_dir]
end
