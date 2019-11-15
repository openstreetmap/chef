name "sarkany"
description "Master role applied to sarkany"

default_attributes(
  :hardware => {
    :shm_size => "8g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "37.17.173.8",
        :prefix => "24",
        :gateway => "37.17.173.254"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:4c48:2:bf04:250:56ff:fe8f:5c81",
        :prefix => "64",
        :gateway => "fe80::224:14ff:fe84:5000"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "6144 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 12800 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 16000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 22400 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 22800 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :nginx => {
    :cache => {
      :proxy => {
        :max_size => "4096M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "budapest.render.openstreetmap.org"
  }
)

run_list(
  "role[szerverem]",
  "role[tilecache]"
)
