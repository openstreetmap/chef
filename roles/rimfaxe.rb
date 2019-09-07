name "rimfaxe"
description "Master role applied to rimfaxe"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "130.225.254.109",
        :prefix => "27",
        :gateway => "130.225.254.97",
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:878:346::109",
        :prefix => "64",
        :gateway => "2001:878:346::97",
      },
    },
  },
  :squid => {
    :cache_mem => "7000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "aalborg.render.openstreetmap.org",
    :tile_siblings => [
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org",
    ],
  }
)

run_list(
  "role[dotsrc]",
  "role[tilecache]"
)
