name "jakelong"
description "Master role applied to jakelong"

default_attributes(
  :hardware => {
    :shm_size => "3g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "71.19.155.177",
        :prefix => "24",
        :gateway => "71.19.155.1"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2605:2700:0:17:a800:ff:fe3e:cdca",
        :prefix => "64",
        :gateway => "2605:2700:0:17::1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "1024 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 3840 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 4800 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 6720 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 8640 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :nginx => {
    :cache => {
      :proxy => {
        :keys_zone => "proxy_cache_zone:64M",
        :max_size => "2048M"
      }
    }
  },
  :sysctl => {
    :kvm => {
      :comment => "Tuning for KVM guest",
      :parameters => {
        "kernel.sched_min_granularity_ns" => 10000000,
        "kernel.sched_wakeup_granularity_ns" => 15000000
      }
    },
    :network_conntrack_max => {
      :comment => "Increase max number of connections tracked",
      :parameters => {
        "net.netfilter.nf_conntrack_max" => "65536"
      }
    }
  },
  :tilecache => {
    :tile_parent => "sanfrancisco.render.openstreetmap.org"
  }
)

run_list(
  "role[prgmr]",
  "role[tilecache]"
)
