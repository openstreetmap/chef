name "naga"
description "Master role applied to naga"

default_attributes(
  :hardware => {
    :shm_size => "14g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "45.13.104.40",
        :prefix => "32",
        :gateway => "10.0.4.1"
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2a0b:cbc0:1101:1::41",
        :prefix => "64",
        :gateway => "2a0b:cbc0:1101:1::1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "10240 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org"
  }
)

run_list(
  "role[milkywan]",
  "role[tilecache]"
)
