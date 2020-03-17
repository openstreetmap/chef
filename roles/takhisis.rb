name "takhisis"
description "Master role applied to takhisis"

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
        :address => "31.3.110.20",
        :prefix => "24",
        :gateway => "31.3.110.1"
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2a03:7900:111:0:31:3:110:20",
        :prefix => "64",
        :gateway => "fe80::225:90ff:fe5d:c1e1"
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
        :directory => "/store/nginx-cache/proxy-cache",
        :max_size => "65536M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "netherlands.render.openstreetmap.org"
  }
)

run_list(
  "role[tuxis]",
  "role[tilecache]"
)
