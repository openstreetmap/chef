name "meraxes"
description "Master role applied to meraxes"

default_attributes(
  :hardware => {
    :shm_size => "36g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp1s0f0",
        :role => :external,
        :family => :inet,
        :address => "51.15.185.90",
        :prefix => "24",
        :gateway => "51.15.185.1"
      },
      :external_ipv6 => {
        :interface => "enp1s0f0",
        :role => :external,
        :family => :inet6,
        :address => "2001:bc8:2d57:100:aa1e:84ff:fe72:e660",
        :prefix => "48",
        :gateway => "2001:bc8:2::2:258:1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "32768 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 12800 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 16000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 22400 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 22800 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org"
  }
)

run_list(
  "role[scaleway]",
  "role[tilecache]"
)
