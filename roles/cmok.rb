name "cmok"
description "Master role applied to cmok"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp5s0",
        :role => :external,
        :family => :inet,
        :address => "31.130.201.40",
        :prefix => "27",
        :gateway => "31.130.201.33"
      },
      :external_ipv6 => {
        :interface => "enp5s0",
        :role => :external,
        :family => :inet6,
        :address => "2001:67c:2268:1005:21e:8cff:fe8c:8d3b",
        :prefix => "64",
        :gateway => "fe80::20c:42ff:feb2:8ff9"
      }
    }
  },
  :squid => {
    :cache_mem => "4096 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "minsk.render.openstreetmap.org",
    :tile_siblings => [
      "trogdor.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org"
    ]
  }
)

run_list(
  "role[datahata]",
  "role[tilecache]"
)
