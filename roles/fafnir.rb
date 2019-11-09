name "fafnir"
description "Master role applied to fafnir"

default_attributes(
  :hardware => {
    :shm_size => "36g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp3s0f0",
        :role => :external,
        :family => :inet,
        :address => "130.239.18.114",
        :prefix => "27",
        :gateway => "130.239.18.97"
      },
      :external_ipv6 => {
        :interface => "enp3s0f0",
        :role => :external,
        :family => :inet6,
        :address => "2001:6b0:e:2a18::114",
        :prefix => "64",
        :gateway => "fe80::5a97:bdff:fe79:dbc0"
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
    :tile_parent => "sweden.render.openstreetmap.org"
  }
)

run_list(
  "role[umu]",
  "role[tilecache]"
)
