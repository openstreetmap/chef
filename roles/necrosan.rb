name "necrosan"
description "Master role applied to necrosan"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "80.67.167.77",
        :prefix => "32",
        :gateway => "10.0.6.1",
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2a0b:cbc0:110d:1::1c",
        :prefix => "64",
        :gateway => "2a0b:cbc0:110d:1::1",
      },
    },
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org",
    :tile_siblings => [
      # "necrosan.openstreetmap.org",
      "nepomuk.openstreetmap.org",
      "noomoahk.openstreetmap.org",
      "norbert.openstreetmap.org",
      "ladon.openstreetmap.org",
      "culebre.openstreetmap.org",
      "gorynych.openstreetmap.org",
    ],
  }
)

run_list(
  "role[milkywan]",
  "role[tilecache]"
)
