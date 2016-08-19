#
# Cookbook Name:: nominatim
# Recipe:: slave
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

master = search(:node, "roles:nominatim-master")[0] # ~FC010
host = master[:nominatim][:master_host]

node.default[:postgresql][:settings][:defaults][:primary_conninfo] = {
  :host => host,
  :port => "5432",
  :user => "replication",
  :passwords => { :bag => "nominatim", :item => "passwords" }
}

node.default[:postgresql][:settings][:defaults][:restore_command] =
  "/usr/bin/rsync #{host}::archive/%f %p"
