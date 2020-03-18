name "boitata"
description "Master role applied to boitata"

default_attributes(
  :hardware => {
    :shm_size => "14g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "200.236.31.207",
        :prefix => "25",
        :gateway => "200.236.31.254"
      },
      :external_ipv6 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet6,
        :address => "2801:82:80ff:8002:216:ccff:feaa:21",
        :prefix => "64",
        :gateway => "fe80::92e2:baff:fe0d:e24"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "8192 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "brazil.render.openstreetmap.org"
  }
)

run_list(
  "role[c3sl]",
  "role[tilecache]"
)
