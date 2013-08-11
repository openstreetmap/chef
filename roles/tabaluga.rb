name "tabaluga"
description "Master role applied to tabaluga"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "5.9.150.236",
        :prefix => "27",
        :gateway => "5.9.150.225"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2a01:4f8:190:33eb::2",
        :prefix => "64",
        :gateway => "fe80::1"
      }
    }
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :ip_bucket_refill => "6144",
    :net_bucket_refill => "24576",
    :tile_parent => "falkenstein.render.openstreetmap.org"
  }
)

run_list(
  "role[hetzner]",
  "role[tilecache]"
)
