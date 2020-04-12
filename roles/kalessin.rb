name "kalessin"
description "Master role applied to kalessin"

default_attributes(
  :hardware => {
    :shm_size => "20g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "185.66.195.245",
        :prefix => "28",
        :gateway => "185.66.195.241"
      },
      :external_ipv6 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet6,
        :address => "2a03:2260:2000:1::5",
        :prefix => "64",
        :gateway => "2a03:2260:2000:1::1"
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
    :tile_parent => "germany.render.openstreetmap.org"
  }
)

run_list(
  "role[ffrl]",
  "role[tilecache]"
)
