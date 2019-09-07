name "naga"
description "Master role applied to naga"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "185.216.27.232",
        :prefix => "24",
        :gateway => "185.216.27.253",
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2a07:abc4:5::27:244",
        :prefix => "24",
        :gateway => "fe80::20c:29ff:fe4d:941b",
      },
    },
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org",
    :tile_siblings => [
      "noomoahk.openstreetmap.org",
      "norbert.openstreetmap.org",
      "ladon.openstreetmap.org",
      "culebre.openstreetmap.org",
    ],
  }
)

run_list(
  "role[proxgroup]",
  "role[tilecache]"
)
