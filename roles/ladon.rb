name "ladon"
description "Master role applied to ladon"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "83.212.2.116",
        :prefix => "29",
        :gateway => "83.212.2.113",
        :bond => {
          :mode => "802.3ad",
          :miimon => "100",
          :xmithashpolicy => "layer3+4",
          :slaves => %w(eth0 eth1),
        },
      },
      :external_ipv6 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet6,
        :address => "2001:648:2ffe:4::116",
        :prefix => "64",
        :gateway => "2001:648:2ffe:4::1",
      },
    },
  },
  :squid => {
    :cache_mem => "6100 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "athens.render.openstreetmap.org",
    :tile_siblings => [
      "trogdor.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org",
    ],
  }
)

run_list(
  "role[grnet]",
  "role[tilecache]"
)
