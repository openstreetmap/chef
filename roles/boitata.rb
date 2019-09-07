name "boitata"
description "Master role applied to boitata"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "200.236.31.207",
        :prefix => "25",
        :gateway => "200.236.31.254",
      },
      :external_ipv6 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet6,
        :address => "2801:82:80ff:8002:216:ccff:feaa:21",
        :prefix => "64",
        :gateway => "fe80::92e2:baff:fe0d:e24",
      },
    },
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "curitiba.render.openstreetmap.org",
    :tile_siblings => [
      "cherufe.openstreetmap.org",
      "ascalon.openstreetmap.org",
      "stormfly-02.openstreetmap.org",
      "jakelong.openstreetmap.org",
    ],
  }
)

run_list(
  "role[c3sl]",
  "role[tilecache]"
)
