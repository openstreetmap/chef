name "matomo"
description "Role applied to all Matomo servers"

default_attributes(
  :apache => {
    :mpm => "event",
    :event => {
      :server_limit => 30,
      :max_request_workers => 1000,
      :threads_per_child => 50,
      :min_spare_threads => 75,
      :max_spare_threads => 175,
      :listen_cores_buckets_ratio => 4
    }
  },
  :mysql => {
    :settings => {
      :mysqld => {
        :innodb_buffer_pool_instances => "128",
        :innodb_buffer_pool_size => "128GB",
        :innodb_flush_log_at_trx_commit => "2",
        :innodb_log_file_size => "16GB",
        :join_buffer_size => "1GB",
        :key_buffer_size => "0",
        :max_connections => "64"
      }
    }
  }
)

run_list(
  "recipe[matomo]"
)
