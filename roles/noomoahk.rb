name "noomoahk"
description "Master role applied to noomoahk"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "91.224.148.166",
        :prefix => "32",
        :gateway => "89.234.156.230",
      },
      :external_ipv6 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet6,
        :address => "2a03:7220:8080:a600::1",
        :prefix => "56",
        :gateway => "fe80::1",
      },
    },
  },
  :squid => {
    :cache_mem => "3100 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org",
    :tile_siblings => [
      # "necrosan.openstreetmap.org", # IO Overloaded
      "nepomuk.openstreetmap.org",
      # "noomoahk.openstreetmap.org",
      "norbert.openstreetmap.org",
      "ladon.openstreetmap.org",
      "culebre.openstreetmap.org",
      "gorynych.openstreetmap.org",
    ],
  }
)

run_list(
  "role[tetaneutral]",
  "role[tilecache]"
)
