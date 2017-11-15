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
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "networking"

keys = data_bag_item("logstash", "keys")

package %w[
  default-jre-headless
  logstash
]

cookbook_file "/var/lib/logstash/lumberjack.crt" do
  source "lumberjack.crt"
  user "root"
  group "logstash"
  mode 0o644
  notifies :restart, "service[logstash]"
end

file "/var/lib/logstash/lumberjack.key" do
  content keys["lumberjack"].join("\n")
  user "root"
  group "logstash"
  mode 0o640
  notifies :restart, "service[logstash]"
end

template "/etc/logstash/conf.d/chef.conf" do
  source "logstash.conf.erb"
  user "root"
  group "root"
  mode 0o644
  notifies :reload, "service[logstash]"
end

file "/etc/logrotate.d/logstash" do
  mode 0o644
end

service "logstash" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

template "/etc/cron.daily/expire-logstash" do
  source "expire.erb"
  owner "root"
  group "root"
  mode 0o755
end

forwarders = search(:node, "recipes:logstash\\:\\:forwarder") # ~FC010

forwarders.sort_by { |n| n[:fqdn] }.each do |forwarder|
  forwarder.interfaces(:role => :external) do |interface|
    firewall_rule "accept-lumberjack-#{forwarder}" do
      action :accept
      family interface[:family]
      source "#{interface[:zone]}:#{interface[:address]}"
      dest "fw"
      proto "tcp:syn"
      dest_ports "5043"
      source_ports "1024:"
    end
  end
end

gateways = search(:node, "roles:gateway") # ~FC010

gateways.sort_by { |n| n[:fqdn] }.each do |gateway|
  gateway.interfaces(:role => :external) do |interface|
    firewall_rule "accept-lumberjack-#{gateway}" do
      action :accept
      family interface[:family]
      source "#{interface[:zone]}:#{interface[:address]}"
      dest "fw"
      proto "tcp:syn"
      dest_ports "5043"
      source_ports "1024:"
    end
  end
end
