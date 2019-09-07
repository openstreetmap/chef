name "culebre"
description "Master role applied to culebre"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "155.210.4.103",
        :prefix => "28",
        :gateway => "155.210.4.110",
      },
      :internal_ipv4 => {
        :interface => "ens4",
        :role => :internal,
        :family => :inet,
        :address => "10.148.97.151",
        :prefix => "24",
      },
    },
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "zaragoza.render.openstreetmap.org",
    :tile_siblings => [
      "trogdor.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "gorynych.openstreetmap.org",
    ],
  }
)

run_list(
  "role[unizar]",
  "role[tilecache]"
)
