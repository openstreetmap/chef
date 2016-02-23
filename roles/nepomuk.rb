name "nepomuk"
description "Master role applied to nepomuk"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "77.95.70.166",
        :prefix => "27",
        :gateway => "77.95.70.161"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2a03:9180:1:21::a6",
        :prefix => "64",
        :gateway => "2a03:9180:1:21::a1"
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
    }
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/vda/queue/nr_requests" => "128",
        "block/vda/queue/scheduler" => "deadline"
      }
    }
  },
  :tilecache => {
    :tile_parent => "lyon.render.openstreetmap.org",
    :tile_siblings => [
      "trogdor.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org"
    ]
  }
)

run_list(
  "role[lyonix]",
  "role[tilecache]"
)
