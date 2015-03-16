name "piwik"
description "Role applied to all Piwik servers"

default_attributes(
  :apache => {
    :mpm => "prefork"
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
