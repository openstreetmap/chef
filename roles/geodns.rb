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
          "193.60.236.20", # sarel
        ],
      },
    },
  }
)

run_list(
  "recipe[rsyncd]",
  "recipe[geodns]"
)
