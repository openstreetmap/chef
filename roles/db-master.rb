name "db-master"
description "Role applied to all the master database server"

default_attributes(
  :postgresql => {
    :versions => ["9.5"],
    :settings => {
      :defaults => {
        :wal_level => "hot_standby",
        :archive_mode => "on",
        :archive_command => "/usr/local/bin/openstreetmap-wal-e --terse wal-push %p",
        :max_wal_senders => "3",
        :late_authentication_rules => [
          { :database => "replication", :user => "replication", :address => "10.0.48.50/32" },
          { :database => "replication", :user => "replication", :address => "10.0.48.5/32" },
          { :database => "replication", :user => "replication", :address => "10.0.0.10/32" },
          { :database => "replication", :user => "replication", :address => "10.0.32.40/32" }
        ]
      }
    }
  }
)

run_list(
  "role[db]",
  "recipe[db::master]",
  "recipe[rsyncd]"
)
