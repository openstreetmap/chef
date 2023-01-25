name "db-master"
description "Role applied to all the master database server"

default_attributes(
  :postgresql => {
    :settings => {
      :defaults => {
        :archive_mode => "on",
        :archive_command => "/usr/local/bin/openstreetmap-wal-g wal-push %p --walg-prevent-wal-overwrite=true"
      }
    }
  }
)

run_list(
  "role[db]",
  "recipe[db::master]",
  "recipe[rsyncd]"
)
