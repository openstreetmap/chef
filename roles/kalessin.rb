name "kalessin"
description "Master role applied to kalessin"

default_attributes(
  :networking => {
    :netplan => true,
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "185.66.195.245",
        :prefix => "28",
        :gateway => "185.66.195.241"
      },
      :external_ipv6 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet6,
        :address => "2a03:2260:2000:1::5",
        :prefix => "64",
        :gateway => "2a03:2260:2000:1::1"
      }
    }
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "germany.render.openstreetmap.org",
    :tile_siblings => [
      "konqi.openstreetmap.org",
      "trogdor.openstreetmap.org",
      "nepomuk.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org",
      "simurgh.openstreetmap.org"
    ]
  }
)

run_list(
  "role[ffrl]",
  "role[geodns]",
  "role[tilecache]"
)
