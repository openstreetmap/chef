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
include_recipe "apt::passenger"
include_recipe "prometheus"
include_recipe "ruby"

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

prometheus_exporter "passenger" do
  port 9149
  user "root"
  environment "PASSENGER_INSTANCE_REGISTRY_DIR" => node[:passenger][:instance_registry_dir]
  options "--passenger.command.timeout-seconds=5"
  restrict_address_families "AF_UNIX"
end
