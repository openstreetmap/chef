name "nominatim-master"
description "Role applied to the master nominatim server"

default_attributes(
  :postgresql => {
    :settings => {
      :defaults => {
        :wal_level => "hot_standby",
        :archive_mode => "on",
        :archive_command => "/bin/cp %p /data/postgresql-archive/%f",
        :max_wal_senders => "5"
      }
    }
  },
  :nominatim => {
    :state => "master",
    :enable_backup => true
  },
  :rsyncd => {
    :modules => {
      :archive => {
        :comment => "WAL Archive",
        :read_only => true,
        :write_only => false,
        :list => false,
        :uid => "postgres",
        :gid => "postgres",
        :transfer_logging => false
      }
    }
  }
)

run_list(
  "recipe[rsyncd]",
  "recipe[nominatim::master]",
  "role[nominatim-base]"
)
