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
  :nginx => {
    :access_log => false
  },
  :sysctl => {
    :sockets => {
      :comment => "Increase size of connection queue",
      :parameters => {
        "net.core.somaxconn" => 10000
      }
    },
    :network_conntrack_time_wait => {
      :comment => "Only track completed connections for 30 seconds",
      :parameters => {
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" => "30"
      }
    },
    :network_conntrack_max => {
      :comment => "Increase max number of connections tracked",
      :parameters => {
        "net.netfilter.nf_conntrack_max" => "524288"
      }
    },
    :network_local_port_range => {
      :comment => "Increase available local port range",
      :parameters => {
        "net.ipv4.ip_local_port_range" => "1024\t65535"
      }
    },
    :network_tcp_timewait_reuse => {
      :comment => "Allow tcp timewait reuse",
      :parameters => {
        "net.ipv4.tcp_tw_reuse" => 1
      }
    },
    :squid_swappiness => {
      :comment => "Prefer not to swapout to free memory",
      :parameters => {
        "vm.swappiness" => "1"
      }
    },
    :sched_wakeup => {
      :comment => "Tune scheduler",
      :parameters => {
        "kernel.sched_min_granularity_ns" => "10000000",
        "kernel.sched_wakeup_granularity_ns" => "15000000"
      }
    }
  },
  :tools => {
    :cron => {
      :load => {
        :nice => 19,
        :io_scheduling_class => "best-effort",
        :io_scheduling_priority => 7
      }
    }
  }
)

run_list(
  "recipe[tilecache]"
)
