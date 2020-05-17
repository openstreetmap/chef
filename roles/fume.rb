name "fume"
description "Master role applied to fume"

default_attributes(
  :hardware => {
    :shm_size => "6g"
  },
  :networking => {
    :hostname => "seshat.civ.zcu.cz",
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "147.228.60.16",
        :prefix => "24",
        :gateway => "147.228.60.1"
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
  "role[zcu]",
  "role[tilecache]"
)
