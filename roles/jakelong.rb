name "jakelong"
description "Master role applied to jakelong"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "71.19.155.177",
        :prefix => "24",
        :gateway => "71.19.155.1",
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2605:2700:0:17:a800:ff:fe3e:cdca",
        :prefix => "64",
        :gateway => "2605:2700:0:17::1",
      },
    },
  },
  :squid => {
    :cache_mem => "1024 MB",
    :cache_dir => "coss /store/squid/coss-01 24000 block-size=8192 max-size=262144 membufs=30",
  },
  :sysctl => {
    :kvm => {
      :comment => "Tuning for KVM guest",
      :parameters => {
        "kernel.sched_min_granularity_ns" => 10000000,
        "kernel.sched_wakeup_granularity_ns" => 15000000,
      },
    },
    :network_conntrack_max => {
      :comment => "Increase max number of connections tracked",
      :parameters => {
        "net.netfilter.nf_conntrack_max" => "65536",
      },
    },
  },
  :tilecache => {
    :tile_parent => "sanfrancisco.render.openstreetmap.org",
    :tile_siblings => [
      "stormfly-02.openstreetmap.org",
      "azure.openstreetmap.org",
      "ascalon.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
    ],
  }
)

run_list(
  "role[prgmr]",
  "role[geodns]",
  "role[tilecache]"
)
