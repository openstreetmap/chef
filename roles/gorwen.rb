name "gorwen"
description "Master role applied to gorwen"

default_attributes(
  :hardware => {
    :shm_size => "20g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "200.25.1.70",
        :prefix => "28",
        :gateway => "200.25.1.65"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2800:1e0:a01:a006::6f",
        :prefix => "125",
        :gateway => "2800:1e0:a01:a006::69"
      }
    },
    :wireguard => {
      :enabled => false
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
        :max_size => "8192M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "bogota.render.openstreetmap.org"
  }
)

run_list(
  "role[edgeuno-co]",
  "role[tilecache]"
)
