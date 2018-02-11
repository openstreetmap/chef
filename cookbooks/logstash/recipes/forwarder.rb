#
# Cookbook Name:: logstash
# Recipe:: default
#
# Copyright 2015, OpenStreetMap Foundation
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

require "json"

package "logstash-forwarder"

cookbook_file "/var/lib/logstash-forwarder/lumberjack.crt" do
  source "lumberjack.crt"
  user "root"
  group "root"
  mode 0o644
  notifies :restart, "service[logstash-forwarder]"
end

file "/etc/logstash-forwarder.conf" do
  content JSON.pretty_generate(node[:logstash][:forwarder])
  user "root"
  group "root"
  mode 0o644
  notifies :restart, "service[logstash-forwarder]"
end

service "logstash-forwarder" do
  action [:enable, :start]
  supports :status => true, :restart => true
end
