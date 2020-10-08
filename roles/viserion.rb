name "viserion"
description "Master role applied to viserion"

default_attributes(
  :accounts => {
    :users => {
      :anovak => { :status => :administrator }
    }
  },
  :hardware => {
    :shm_size => "36g"
  },
  :location => "Pula, Croatia",
  :munin => {
    :allow => ["193.198.233.210"]
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "193.198.233.211",
        :prefix => "29",
        :gateway => "193.198.233.209"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:b68:4cff:3::3",
        :prefix => "64",
        :gateway => "2001:b68:4cff:3::1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "32768 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "pula.render.openstreetmap.org"
  }
)

run_list(
  "role[carnet]",
  "role[tilecache]"
)
