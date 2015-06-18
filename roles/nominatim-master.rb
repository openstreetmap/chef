name "nominatim-master"
description "Role applied to the master nominatim server"

default_attributes(
  :postgresql => {
    :versions => ["9.3"],
    :settings => {
      :defaults => {
        :wal_level => "hot_standby",
        :archive_mode => "on",
        :archive_command => "/bin/cp %p /data/postgresql-archive/%f",
        :max_wal_senders => "5",
        :late_authentication_rules => [
          { :database => "replication", :user => "replication", :address => "146.179.159.164/32" }
        ]
      }
    }
  },
  :nominatim => {
    :enable_backup => true
  },
  :rsyncd => {
    :modules => {
      :archive => {
        :comment => "WAL Archive",
        :path => "/data/postgresql-archive",
        :read_only => true,
        :write_only => false,
        :list => false,
        :uid => "postgres",
        :gid => "postgres",
        :transfer_logging => false,
        :hosts_allow => [
          "146.179.159.164"
        ]
      }
    }
  }
)

run_list(
  "role[nominatim]",
  "recipe[nominatim::master]",
  "recipe[rsyncd]"
)
