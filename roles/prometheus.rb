name "prometheus"
description "Role applied to all prometheus servers"

default_attributes(
  :postgresql => {
    :settings => {
      :defaults => {
        :max_connections => "500",
        :shared_buffers => "48GB",
        :work_mem => "8MB",
        :maintenance_work_mem => "2GB",
        :effective_io_concurrency => "200",
        :max_worker_processes => "67",
        :max_parallel_workers_per_gather => "28",
        :max_parallel_workers => "56",
        :wal_buffers => "16MB",
        :max_wal_size => "32GB",
        :min_wal_size => "4GB",
        :checkpoint_completion_target => "0.9",
        :random_page_cost => "1.1",
        :effective_cache_size => "144GB",
        :default_statistics_target => "500",
        :log_autovacuum_min_duration => "0",
        :autovacuum_max_workers => "56",
        :autovacuum_naptime => "1",
        :autovacuum_multixact_freeze_max_age => "200000000",
        :max_locks_per_transaction => "512"
      }
    }
  }
)

run_list(
  "recipe[prometheus::server]"
)
