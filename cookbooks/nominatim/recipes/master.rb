#
# Cookbook Name:: nominatim
# Recipe:: master
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

slaves = search(:node, "roles:nominatim-slave") # ~FC010

node.default[:postgresql][:settings][:defaults][:late_authentication_rules] = []
node.default[:rsyncd][:modules] = { :archive => { :hosts_allow => [] } }

slaves.each do |slave|
  # set up DB access for each slave
  node.default[:postgresql][:settings][:defaults][:late_authentication_rules].push(
    :database => "replication",
    :user => "replication",
    :address => "#{slave[:networking][:internal_ipv4][:address]}/32"
  )
  # allow slaves access to the WAL logs
  node.default[:rsyncd][:modules][:archive][:hosts_allow].push(
    slave[:networking][:internal_ipv4][:address]
  )
end
