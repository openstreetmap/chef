name "shruikan"
description "Master role applied to shruikan"

default_attributes(
  :hardware => {
    :shm_size => "14g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "45.148.169.51",
        :prefix => "25",
        :gateway => "45.148.169.1"
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2a0a:aa42:56:1000::1",
        :prefix => "48",
        :gateway => "2a0a:aa42:56::1"
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
        :max_size => "16384M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "netherlands.render.openstreetmap.org"
  }
)

run_list(
  "role[greenmini]",
  "role[tilecache]"
)
