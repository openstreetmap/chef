name "norbert"
description "Master role applied to norbert"

default_attributes(
  :hardware => {
    :shm_size => "12g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "89.234.186.100",
        :prefix => "27",
        :gateway => "89.234.186.97"
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2a00:5884:821c::1",
        :prefix => "48",
        :gateway => "fe80::204:92:100:1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "10240 MB",
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
        :keys_zone => "proxy_cache_zone:64M",
        :max_size => "2048M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org"
  }
)

run_list(
  "role[grifon]",
  "role[tilecache]"
)
