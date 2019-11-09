name "vipertooth"
description "Master role applied to vipertooth"

default_attributes(
  :hardware => {
    :shm_size => "18g"
  },
  :location => "Kiev, Ukraine",
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet,
        :address => "176.122.99.101",
        :prefix => "26",
        :gateway => "176.122.99.126"
      },
      :external_ipv6 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet6,
        :address => "2001:67c:2d40::65",
        :prefix => "64",
        :gateway => "2001:67c:2d40::fffe"
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
  :tilecache => {
    :tile_parent => "kiev.render.openstreetmap.org"
  }
)

run_list(
  "role[utelecom]",
  "role[tilecache]"
)
