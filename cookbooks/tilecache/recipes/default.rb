#
# Cookbook Name:: tilecache
# Recipe:: default
#
# Copyright 2011, OpenStreetMap Foundation
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

include_recipe "squid"

tilecaches = search(:node, "roles:tilecache").sort_by { |n| n[:hostname] }

tilecaches.each do |cache|
  cache.ipaddresses(:family => :inet, :role => :external).sort.each do |address|
    firewall_rule "accept-squid" do
      action :accept
      family "inet"
      source "net:#{address}"
      dest "fw"
      proto "tcp:syn"
      dest_ports "3128"
      source_ports "1024:"
    end
    firewall_rule "accept-squid-icp" do
      action :accept
      family "inet"
      source "net:#{address}"
      dest "fw"
      proto "udp"
      dest_ports "3130"
      source_ports "1024:"
    end
  end
end

squid_fragment "tilecache" do
  template "squid.conf.erb"
  variables :caches => tilecaches
end
