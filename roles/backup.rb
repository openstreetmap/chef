name "backup"
description "Role applied to backup.openstreetmap.org"

default_attributes(
  :accounts => {
    :users => {
      :osmbackup => { :status => :role }
    }
  },
  :rsyncd => {
    :modules => {
      :backup => {
        :comment => "Backups",
        :path => "/store/backup",
        :read_only => false,
        :write_only => true,
        :list => false,
        :uid => "osmbackup",
        :gid => "osmbackup",
        :transfer_logging => false,
        :hosts_allow => [
          "128.40.168.0/24",                     # ucl external (wates)
          "128.40.45.192/27",                    # ucl external (wolfson)
          "146.179.159.160/27",                  # ic internal
          "193.63.75.96/27",                     # ic external
          "2001:630:12:500::/64",                # ic external
          "2001:41c8:10:996:21d:7dff:fec3:df70", # shenron
          "127.0.0.0/8",                         # localhost
          "::1"                                  # localhost
        ]
      }
    }
  }
)

run_list(
  "recipe[rsyncd]",
  "recipe[backup]"
)
