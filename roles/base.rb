name "base"
description "Base role applied to all servers"

default_attributes(
  :accounts => {
    :users => {
      :grant => { :status => :administrator },
      :tomh => { :status => :administrator },
      :matt => { :status => :administrator },
      :jburgess => { :status => :administrator }
    }
  },
  :munin => {
    :plugins => {
      :chrony => {
        :systime => { :warning => "100", :critical => "250" }
      }
    }
  },
  :networking => {
    :roles => {
      :internal => { :metric => 200, :zone => "loc" },
      :external => { :metric => 100, :zone => "osm" }
    },
    :search => ["openstreetmap.org"]
  },
  :sysctl => {
    :panic => {
      :comment => "Reboot automatically after a panic",
      :parameters => { "kernel.panic" => "60" }
    },
    :blackhole => {
      :comment => "Do TCP level MTU probing if we seem to have an ICMP blackhole",
      :parameters => {
        "net.ipv4.tcp_mtu_probing" => "1",
        "net.ipv4.tcp_base_mss" => "1024"
      }
    },
    :network_buffers => {
      :comment => "Tune network buffers",
      :parameters => {
        "net.core.rmem_max" => "16777216",
        "net.core.wmem_max" => "16777216",
        "net.ipv4.tcp_rmem" => "4096 87380 16777216",
        "net.ipv4.tcp_wmem" => "4096 65536 16777216",
        "net.ipv4.udp_mem" => "3145728 4194304 16777216"
      }
    },
    :network_backlog => {
      :comment => "Increase maximum backlog for incoming network packets",
      :parameters => {
        "net.core.netdev_max_backlog" => "2500",
        "net.core.netdev_budget" => "600"
      }
    },
    :network_conntrack_established => {
      :comment => "Only track established connections for four hours",
      :parameters => {
        "net.netfilter.nf_conntrack_tcp_timeout_established" => "14400"
      }
    },
    :tcp_syncookies => {
      :comment => "Turn on syncookies to protect against SYN floods",
      :parameters => {
        "net.ipv4.tcp_syncookies" => "1"
      }
    },
    :default_qdisc => {
      :comment => "Use fq as the default queuing discipline and cubic for congestion control",
      :parameters => {
        "net.core.default_qdisc" => "fq",
        "net.ipv4.tcp_congestion_control" => "cubic"
      }
    },
    :tune_cpu_scheduler => {
      :comment => "Tune CPU scheduler for server scheduling",
      :parameters => {
        "kernel.sched_migration_cost_ns" => 50000000,
        "kernel.sched_autogroup_enabled" => 0
      }
    }
  }
)

run_list(
  "recipe[accounts]",
  "recipe[apt]",
  "recipe[chef]",
  "recipe[devices]",
  "recipe[hardware]",
  "recipe[prometheus]",
  "recipe[munin::plugins]",
  "recipe[networking]",
  "recipe[exim]",
  "recipe[ntp]",
  "recipe[openssh]",
  "recipe[sysctl]",
  "recipe[sysfs]",
  "recipe[tools]",
  "recipe[fail2ban]"
)
