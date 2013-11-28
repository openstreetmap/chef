name "db-master"
description "Role applied to all the master database server"

default_attributes(
  :postgresql => {
    :versions => [ "9.1" ],
    :settings => {
      :defaults => {
        :wal_level => "hot_standby",
        :archive_mode => "on",
        :archive_command => "/bin/cp %p /store/postgresql/archive/%f",
        :max_wal_senders => "2",
        :user_name_maps => {
          :backup => [
            { :system => "osmbackup", :postgres => "backup" }
          ]
        },
        :early_authentication_rules => [
          { :type => "local", :database => "all", :user => "backup", :method => "peer", :options => { :map => "backup" } }
        ],
        :late_authentication_rules => [
          { :database => "replication", :user => "replication", :address => "146.179.159.168/32" },
          { :database => "replication", :user => "replication", :address => "146.179.159.173/32" }
        ]
      }
    }
  },
  :rsyncd => {
    :modules => {
      :archive => {
        :comment => "WAL Archive",
        :path => "/store/postgresql/system/archive",
        :read_only => true,
        :write_only => false,
        :list => false,
        :uid => "postgres",
        :gid => "postgres",
        :transfer_logging => false,
        :hosts_allow => [
          "146.179.159.168"
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
