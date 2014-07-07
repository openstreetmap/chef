#
# Cookbook Name:: passenger
# Recipe:: default
#
# Copyright 2014, OpenStreetMap Foundation
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

include_recipe "apache"

package "ruby#{node[:passenger][:ruby_version]}"
package "ruby#{node[:passenger][:ruby_version]}-dev"
package "rubygems#{node[:passenger][:ruby_version]}"
package "irb#{node[:passenger][:ruby_version]}"

template "/usr/local/bin/passenger-ruby" do
  source "ruby.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :reload, "service[apache2]"
end

apache_module "passenger" do
  version node[:passenger][:version]
  conf "passenger.conf.erb"
end

package "passenger-common#{node[:passenger][:ruby_version]}"

munin_plugin "passenger_memory"
munin_plugin "passenger_processes"
munin_plugin "passenger_queues"
munin_plugin "passenger_requests"
