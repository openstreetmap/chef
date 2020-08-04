name "lockheed"
description "Master role applied to lockheed"

default_attributes(
  :accounts => {
    :administrators => %w[luc qt fat115 tcit chocobozzz qdupont josephk spf pyg]
  },
  :hardware => {
    :shm_size => "12g"
  },
  :location => "Falkenstein, Germany",
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens13",
        :role => :external,
        :family => :inet,
        :address => "176.9.171.103",
        :prefix => "28",
        :gateway => "176.9.171.97"
      },
      :external_ipv6 => {
        :interface => "ens13",
        :role => :external,
        :family => :inet6,
        :address => "2a01:4f8:13a:209::103",
        :prefix => "64",
        :gateway => "2a01:4f8:13a:209::3"
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
    :tile_parent => "france.render.openstreetmap.org"
  }
)

run_list(
  "role[hetzner]",
  "role[tilecache]"
)
