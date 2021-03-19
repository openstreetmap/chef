#
# Cookbook:: timescaledb
# Recipe:: default
#
# Copyright:: 2021, OpenStreetMap Foundation
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

include_recipe "apt"

database_version = node[:timescaledb][:database_version]

package %W[
  timescaledb-tools
  timescaledb-2-postgresql-#{database_version}
]

node.default_unless[:postgresql][:versions] = []
node.default[:postgresql][:versions] |= [database_version]
node.default[:postgresql][:monitor_tables] = false
node.default_unless[:postgresql][:settings][database_version][:shared_preload_libraries] = []
node.default[:postgresql][:settings][database_version][:shared_preload_libraries] |= ["timescaledb"]
node.default_unless[:postgresql][:settings][database_version][:customized_options] = {}
node.default[:postgresql][:settings][database_version][:customized_options]["timescaledb.max_background_workers"] = node[:timescaledb][:max_background_workers]

include_recipe "postgresql"
