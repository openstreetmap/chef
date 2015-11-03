name "tilecache"
description "Role applied to all tile cache servers"

default_attributes(
  :accounts => {
    :groups => {
      :proxy => {
        :members => [:tomh, :grant, :matt, :jburgess]
      }
    }
  },
  :apt => {
    :sources => ["nginx"]
  },
  :sysctl => {
    :network_conntrack_time_wait => {
      :comment => "Only track completed connections for 30 seconds",
      :parameters => {
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" => "30"
      }
    },
    :network_conntrack_max => {
      :comment => "Increase max number of connections tracked",
      :parameters => {
        "net.netfilter.nf_conntrack_max" => "131072"
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
