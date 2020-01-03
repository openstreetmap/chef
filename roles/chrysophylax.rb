name "chrysophylax"
description "Master role applied to chrysophylax"

default_attributes(
  :hardware => {
    :shm_size => "14g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet,
        :address => "217.71.244.22",
        :prefix => "30",
        :gateway => "217.71.244.21"
      },
      :external_ipv6 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet6,
        :address => "2001:8e0:40:2039::10",
        :prefix => "64",
        :gateway => "2001:8e0:40:2039::1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "10240 MB",
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
        :max_size => "16384M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "zurich.render.openstreetmap.org"
  }
)

run_list(
  "role[iway]",
  "role[geodns]",
  "role[tilecache]"
)
