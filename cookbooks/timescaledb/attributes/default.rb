default[:timescaledb][:cluster] = "12/main"
default[:timescaledb][:max_background_workers] = 8

database_version = node[:timescaledb][:cluster].split("/").first

default[:apt][:sources] |= ["timescaledb"]

memory_gb = (node[:memory][:total].to_f / 1024 / 1024).ceil

default[:postgresql][:versions] |= [database_version]
default[:postgresql][:settings][database_version][:max_connections] = 500
default[:postgresql][:settings][database_version][:shared_buffers] = "#{memory_gb / 4}GB"
default[:postgresql][:settings][database_version][:work_mem] = "#{memory_gb * 128 / 50 / node[:cpu][:total]}MB"
default[:postgresql][:settings][database_version][:maintenance_work_mem] = "2GB"
default[:postgresql][:settings][database_version][:effective_io_concurrency] = "200"
default[:postgresql][:settings][database_version][:max_worker_processes] = node[:cpu][:total] + node[:timescaledb][:max_background_workers] + 3
default[:postgresql][:settings][database_version][:max_parallel_workers_per_gather] = node[:cpu][:total] / 2
default[:postgresql][:settings][database_version][:max_parallel_workers] = node[:cpu][:total]
default[:postgresql][:settings][database_version][:wal_buffers] = "16MB"
default[:postgresql][:settings][database_version][:max_wal_size] = "1GB"
default[:postgresql][:settings][database_version][:min_wal_size] = "512MB"
default[:postgresql][:settings][database_version][:checkpoint_completion_target] = "0.9"
default[:postgresql][:settings][database_version][:random_page_cost] = "1.1"
default[:postgresql][:settings][database_version][:effective_cache_size] = "#{memory_gb * 3 / 4}GB"
default[:postgresql][:settings][database_version][:default_statistics_target] = "500"
default[:postgresql][:settings][database_version][:autovacuum_max_workers] = "10"
default[:postgresql][:settings][database_version][:autovacuum_naptime] = "10"
default_unless[:postgresql][:settings][database_version][:shared_preload_libraries] = []
default[:postgresql][:settings][database_version][:shared_preload_libraries] |= ["timescaledb"]
default[:postgresql][:settings][database_version][:max_locks_per_transaction] = "512"
default_unless[:postgresql][:settings][database_version][:customized_options] = {}
default[:postgresql][:settings][database_version][:customized_options]["timescaledb.max_background_workers"] = node[:timescaledb][:max_background_workers]
