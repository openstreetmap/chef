name "stormfly-03"
description "Master role applied to stormfly-03"

default_attributes(
  :hardware => {
    :shm_size => "38g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "140.211.167.99",
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :external_ipv6 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet6,
        :address => "2605:bc80:3010:700::8cd3:a763"
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
  :nginx => {
    :cache => {
      :proxy => {
        :max_size => "65536M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "corvallis.render.openstreetmap.org"
  }
)

run_list(
  "role[osuosl]",
  "role[hp-g9]",
  "role[tilecache]"
)
