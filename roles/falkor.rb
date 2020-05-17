name "falkor"
description "Master role applied to falkor"

default_attributes(
  :hardware => {
    :shm_size => "6g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet,
        :address => "81.27.197.69",
        :prefix => "26",
        :gateway => "81.27.197.65"
      },
      :external_ipv6 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet6,
        :address => "2a02:8301:0:1::69",
        :prefix => "64",
        :gateway => "2a02:8301:0:1::1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "4096 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "czechia.render.openstreetmap.org"
  }
)

run_list(
  "role[vodafone-cz]",
  "role[tilecache]"
)
