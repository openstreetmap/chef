name "simurgh"
description "Master role applied to simurgh"

default_attributes(
  :hardware => {
    :shm_size => "18g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens32",
        :role => :external,
        :family => :inet,
        :address => "94.20.20.55",
        :prefix => "24",
        :gateway => "94.20.20.1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "16384 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
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
  :tilecache => {
    :tile_parent => "baku.render.openstreetmap.org"
  }
)

run_list(
  "role[delta]",
  "role[tilecache]"
)
