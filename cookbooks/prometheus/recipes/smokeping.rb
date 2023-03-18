#
# Cookbook:: prometheus
# Recipe:: smokeping
#
# Copyright:: 2023, OpenStreetMap Foundation
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

ip4_hosts = []
ip6_hosts = []

search(:node, "networking:interfaces") do |host|
  next if host.name == node.name

  ip4_hosts << host[:fqdn] unless host.ipaddresses(:role => :external, :family => :inet).empty?
  ip6_hosts << host[:fqdn] unless host.ipaddresses(:role => :external, :family => :inet6).empty?
end

template "/etc/prometheus/exporters/smokeping.yml" do
  source "smokeping.yml.erb"
  owner "root"
  group "root"
  mode "644"
  variables :ip4_hosts => ip4_hosts, :ip6_hosts => ip6_hosts
end

prometheus_exporter "smokeping" do
  port 9374
  options "--config.file=/etc/prometheus/exporters/smokeping.yml"
  capability_bounding_set "CAP_NET_RAW"
  ambient_capabilities "CAP_NET_RAW"
  private_users false
  subscribes :restart, "template[/etc/prometheus/exporters/smokeping.yml]"
end
