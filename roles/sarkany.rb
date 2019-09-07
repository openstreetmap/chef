name "sarkany"
description "Master role applied to sarkany"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "37.17.173.8",
        :prefix => "24",
        :gateway => "37.17.173.254",
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:4c48:2:bf04:250:56ff:fe8f:5c81",
        :prefix => "64",
        :gateway => "fe80::224:14ff:fe84:5000",
      },
    },
  },
  :squid => {
    :cache_mem => "5100 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "budapest.render.openstreetmap.org",
    :tile_siblings => [
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org",
    ],
  }
)

run_list(
  "role[szerverem]",
  "role[tilecache]"
)
