name "kokosnuss"
description "Master role applied to kokosnuss"

default_attributes(
  :hardware => {
    :shm_size => "12g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "venet0",
        :role => :external,
        :family => :inet,
        :address => "85.214.255.86",
        :prefix => "32",
        :gateway => "85.214.255.86"
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
  :tilecache => {
    :tile_parent => "germany.render.openstreetmap.org"
  }
)

run_list(
  "role[strato]",
  "role[tilecache]"
)
