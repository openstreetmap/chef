name "backup"
description "Role applied to backup.openstreetmap.org"

default_attributes(
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
          "193.60.236.0/24",                     # ucl external
          "10.0.48.0/20",                        # equinix internal
          "130.117.76.0/27",                     # equinix external
          "2001:978:2:2C::172:0/112",            # equinix external
          "10.0.32.0/20",                        # bytemark internal
          "89.16.162.16/28",                     # bytemark external
          "2001:41c9:2:d6::/64",                 # bytemark external
          "212.110.172.32",                      # shenron
          "2001:41c9:1:400::32",                 # shenron
          "140.211.167.104",                     # osuosl
          "140.211.167.105",                     # osuosl
          "2605:bc80:3010:700::8cde:a768",       # osuosl
          "2605:bc80:3010:700::8cde:a769",       # osuosl
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
