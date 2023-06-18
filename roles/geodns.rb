name "geodns"
description "Role applied to all geographic DNS servers"

default_attributes(
  :rsyncd => {
    :modules => {
      :geodns => {
        :comment => "GeoDNS",
        :path => "/etc/gdnsd/config.d",
        :read_only => false,
        :write_only => true,
        :list => false,
        :transfer_logging => false,
        :hosts_allow => [
          "184.104.226.102",  # idris
          "2001:470:1:b3b::6" # idris
        ]
      }
    }
  }
)

run_list(
  "recipe[rsyncd]",
  "recipe[geodns]"
)
