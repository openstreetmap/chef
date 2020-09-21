name "fuchur"
description "Master role applied to fuchur"

default_attributes(
  :hardware => {
    :shm_size => "12g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet,
        :address => "200.25.58.164",
        :prefix => "27",
        :gateway => "200.25.58.161"
      },
      :external_ipv6 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet6,
        :address => "2800:1e0:1020::44",
        :prefix => "123",
        :gateway => "2800:1e0:1020::41"
      }
    },
    :wireguard => {
      :enabled => false
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
  :nginx => {
    :cache => {
      :proxy => {
        :max_size => "8192M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "brazil.render.openstreetmap.org"
  }
)

run_list(
  "role[edgeuno-br]",
  "role[tilecache]"
)
