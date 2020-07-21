#
# Cookbook:: logstash
# Recipe:: default
#
# Copyright:: 2015, OpenStreetMap Foundation
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

require "yaml"

include_recipe "apt"

package "filebeat"

cookbook_file "/etc/filebeat/filebeat.crt" do
  source "beats.crt"
  user "root"
  group "root"
  mode "600"
  notifies :restart, "service[filebeat]"
end

file "/etc/filebeat/filebeat.yml" do
  content YAML.dump(node[:logstash][:forwarder].to_hash)
  user "root"
  group "root"
  mode "600"
  notifies :restart, "service[filebeat]"
end

service "filebeat" do
  action [:enable, :start]
  supports :status => true, :restart => true
end
