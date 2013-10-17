name "tilecache"
description "Role applied to all tile cache servers"

default_attributes(
  :sysctl => {
    :network_conntrack_time_wait => {
      :comment => "Only track completed connections for 30 seconds",
      :parameters => { 
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" => "30"
      }
    },
    :squid_swappiness => {
      :comment => "Prefer not to swapout to free memory",
      :parameters => { 
        "vm.swappiness" => "30"
      }
    }
  }
)

run_list(
  "role[geodns]",
  "recipe[tilecache]"
)
