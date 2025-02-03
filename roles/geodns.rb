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
          "184.104.226.102",  # idris HE
          "2001:470:1:b3b::6", # idris HE
          "87.252.214.102", # idris Equinix
          "2001:4d78:fe03:1c::6" # idris  Equinix
        ]
      }
    }
  }
)

run_list(
  "recipe[rsyncd]",
  "recipe[geodns]"
)
