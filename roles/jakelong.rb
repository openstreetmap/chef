name "jakelong"
description "Master role applied to jakelong"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "64.62.205.202",
        :prefix => "26",
        :gateway => "64.62.205.193"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:470:1:41:a800:ff:fe3e:cdca",
        :prefix => "64",
        :gateway => "fe80::260:ddff:fe46:623d"
      }
    }
  },
  :squid => {
    :version => 3,
    :cache_mem => "400 MB",
    :cache_dir => "rock /store/squid/rock-01 7500 swap-timeout=500 max-swap-rate=100 slot-size=4096 max-size=262144"
  },
  :sysctl => {
    :kvm => {
      :comment => "Tuning for KVM guest",
      :parameters => {
        "kernel.sched_min_granularity_ns" => 10000000,
        "kernel.sched_wakeup_granularity_ns" => 15000000
      }
    }
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/xvda/queue/scheduler" => "deadline"
      }
    }
  },
  :tilecache => {
    :tile_parent => "sanfrancisco.render.openstreetmap.org",
    :tile_siblings => [
      "stormfly-02.openstreetmap.org",
      "ascalon.openstreetmap.org",
      "nepomuk.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org"
    ]
  }
)

run_list(
  "role[prgmr]",
  "role[geodns]",
  "role[tilecache]"
)
