name "piwik"
description "Role applied to all Piwik servers"

default_attributes(
  :apache => {
    :mpm => "event",
    :event => {
      :server_limit => 18,
      :max_request_workers => 450,
      :min_spare_threads => 50,
      :max_spare_threads => 150,
      :listen_cores_buckets_ratio => 4
    }
  },
  :mysql => {
    :settings => {
      :mysqld => {
        :innodb_buffer_pool_instances => "8",
        :innodb_buffer_pool_size => "16GB",
        :innodb_flush_log_at_trx_commit => "2"
      }
    }
  }
)

run_list(
  "recipe[piwik]"
)
