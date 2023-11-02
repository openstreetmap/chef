name "db-master"
description "Role applied to all the master database server"

default_attributes(
  :postgresql => {
    :monitor_queries => true,
    :settings => {
      :defaults => {
        :archive_mode => "on",
        :archive_command => "/usr/local/bin/openstreetmap-wal-g wal-push %p --walg-prevent-wal-overwrite=true",
        :wal_keep_size => "16384"
      }
    }
  }
)

run_list(
  "role[db]",
  "recipe[db::master]",
  "recipe[rsyncd]"
)
