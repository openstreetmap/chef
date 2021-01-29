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

memory_gb = (node[:memory][:total].to_f / 1024 / 1024).ceil

node.default_unless[:postgresql][:versions] = []
node.default[:postgresql][:versions] |= [database_version]
node.default[:postgresql][:settings][database_version][:max_connections] = 500
node.default[:postgresql][:settings][database_version][:shared_buffers] = "#{memory_gb / 4}GB"
node.default[:postgresql][:settings][database_version][:work_mem] = "#{memory_gb * 128 / 50 / node[:cpu][:total]}MB"
node.default[:postgresql][:settings][database_version][:maintenance_work_mem] = "2GB"
node.default[:postgresql][:settings][database_version][:effective_io_concurrency] = "200"
node.default[:postgresql][:settings][database_version][:max_worker_processes] = node[:cpu][:total] + node[:timescaledb][:max_background_workers] + 3
node.default[:postgresql][:settings][database_version][:max_parallel_workers_per_gather] = node[:cpu][:total] / 2
node.default[:postgresql][:settings][database_version][:max_parallel_workers] = node[:cpu][:total]
node.default[:postgresql][:settings][database_version][:wal_buffers] = "16MB"
node.default[:postgresql][:settings][database_version][:max_wal_size] = "1GB"
node.default[:postgresql][:settings][database_version][:min_wal_size] = "512MB"
node.default[:postgresql][:settings][database_version][:checkpoint_completion_target] = "0.9"
node.default[:postgresql][:settings][database_version][:random_page_cost] = "1.1"
node.default[:postgresql][:settings][database_version][:effective_cache_size] = "#{memory_gb * 3 / 4}GB"
node.default[:postgresql][:settings][database_version][:default_statistics_target] = "500"
node.default[:postgresql][:settings][database_version][:autovacuum_max_workers] = "10"
node.default[:postgresql][:settings][database_version][:autovacuum_naptime] = "10"
node.default_unless[:postgresql][:settings][database_version][:shared_preload_libraries] = []
node.default[:postgresql][:settings][database_version][:shared_preload_libraries] |= ["timescaledb"]
node.default[:postgresql][:settings][database_version][:max_locks_per_transaction] = "512"
node.default_unless[:postgresql][:settings][database_version][:customized_options] = {}
node.default[:postgresql][:settings][database_version][:customized_options]["timescaledb.max_background_workers"] = node[:timescaledb][:max_background_workers]

include_recipe "postgresql"
