name "db-master"
description "Role applied to all the master database server"

default_attributes(
  :postgresql => {
    :settings => {
      :defaults => {
        :wal_level => "logical",
        :archive_mode => "on",
        :archive_command => "/usr/local/bin/openstreetmap-wal-g wal-push %p --walg-prevent-wal-overwrite=true",
        :max_wal_senders => "10",
        :max_replication_slots => "1",
        :late_authentication_rules => [
          { :database => "replication", :user => "replication", :address => "10.0.0.4/32" },   # snap-02
          { :database => "replication", :user => "replication", :address => "10.0.0.10/32" },  # eddie
          { :database => "replication", :user => "replication", :address => "10.0.32.40/32" }, # katla
          { :database => "replication", :user => "replication", :address => "10.0.48.49/32" }, # snap-01
          { :database => "replication", :user => "replication", :address => "10.0.48.50/32" }, # karm
          { :database => "replication", :user => "replication", :address => "10.0.64.50/32" }  # snap-03
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
