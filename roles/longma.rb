name "longma"
description "Master role applied to longma"

default_attributes(
  :exim => {
    :aliases => {
      :root => "ceasar"
    }
  },
  :hardware => {
    :shm_size => "20g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet,
        :address => "140.110.240.7",
        :prefix => "24",
        :gateway => "140.110.240.254"
      },
      :external_ipv6 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet6,
        :address => "2001:e10:2000:240::7",
        :prefix => "64",
        :gateway => "2001:e10:2000:240::254"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "16384 MB",
    :cache_dir => [
      "rock /store.new-san/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store.new-san/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store.new-san/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store.new-san/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :nginx => {
    :cache => {
      :proxy => {
        :directory => "/store.new-san/nginx-cache/proxy-cache",
        :max_size => "65536M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "hsinchu.render.openstreetmap.org"
  }
)

run_list(
  "role[nchc]",
  "role[tilecache]"
)
