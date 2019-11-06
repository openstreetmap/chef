name "drogon"
description "Master role applied to drogon"

default_attributes(
  :accounts => {
    :users => {
      :zelja => { :status => :administrator }
    }
  },
  :hardware => {
    :shm_size => "18g"
  },
  :location => "Osijek, Croatia",
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "161.53.30.107",
        :prefix => "27",
        :gateway => "161.53.30.97"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:b68:c0ff:0:221:5eff:fe40:c7c4",
        :prefix => "64",
        :gateway => "fe80::161:53:30:97"
      }
    },
    :nameservers => [
      "161.53.30.100",
      "8.8.8.8"
    ]
  },
  :squid => {
    :version => 4,
    :cache_mem => "16384 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 12800 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 16000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 22400 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 22800 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "osijek.render.openstreetmap.org",
    :tile_siblings => [
      "viserion.openstreetmap.org"
    ]
  }
)

run_list(
  "role[carnet]",
  "role[tilecache]"
)
