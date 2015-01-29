name "konqi"
description "Master role applied to konqi"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "p2p1",
        :role => :external,
        :family => :inet,
        :address => "81.7.11.83",
        :prefix => "24",
        :gateway => "81.7.11.1"
      },
      :external_ipv6 => {
        :interface => "p2p1",
        :role => :external,
        :family => :inet6,
        :address => "2a02:180:1:1::517:b53",
        :prefix => "64",
        :gateway => "2a02:180:1:1::1"
      }
    }
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "germany.render.openstreetmap.org",
    :tile_siblings => [
       "tabaluga.openstreetmap.org",
       "katie.openstreetmap.org",
       "trogdor.openstreetmap.org",
       "nepomuk.openstreetmap.org",
       "ridgeback.openstreetmap.org",
       "fume.openstreetmap.org",
       "gorynych.openstreetmap.org",
       "simurgh.openstreetmap.org"
    ]
  }
)

run_list(
  "role[euserv]",
  "role[tilecache]"
)
