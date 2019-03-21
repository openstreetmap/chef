name "norbert"
description "Master role applied to norbert"

default_attributes(
  :networking => {
    :netplan => true,
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "89.234.186.100",
        :prefix => "27",
        :gateway => "89.234.186.97"
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2a00:5884:821c::1",
        :prefix => "48",
        :gateway => "fe80::204:92:100:1"
      }
    }
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org",
    :tile_siblings => [
      "noomoahk.openstreetmap.org",
      "nepomuk.openstreetmap.org",
      "necrosan.openstreetmap.org",
      "ladon.openstreetmap.org",
      "culebre.openstreetmap.org"
    ]
  }
)

run_list(
  "role[grifon]",
  "role[tilecache]"
)
