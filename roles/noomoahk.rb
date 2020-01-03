name "noomoahk"
description "Master role applied to noomoahk"

default_attributes(
  :hardware => {
    :shm_size => "6g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "91.224.148.166",
        :prefix => "32",
        :gateway => "89.234.156.230"
      },
      :external_ipv6 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet6,
        :address => "2a03:7220:8080:a600::1",
        :prefix => "56",
        :gateway => "fe80::1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "3072 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 12800 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 16000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 22400 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 22800 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org"
  }
)

run_list(
  "role[tetaneutral]",
  "role[tilecache]"
)
