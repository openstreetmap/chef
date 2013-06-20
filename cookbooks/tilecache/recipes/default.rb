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

expiry_time = 14 * 86400

tilecaches = search(:node, "roles:tilecache").reject { |n| Time.now - Time.at(n[:ohai_time]) > expiry_time }.sort_by { |n| n[:hostname] }.map do |n|
  { :name => n[:hostname], :interface => n.interfaces(:role => :external).first[:interface] }
end

squid_fragment "tilecache" do
  template "squid.conf.erb"
  variables :caches => tilecaches
end
