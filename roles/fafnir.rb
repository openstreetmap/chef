name "fafnir"
description "Master role applied to fafnir"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp3s0f0",
        :role => :external,
        :family => :inet,
        :address => "130.239.18.114",
        :prefix => "27",
        :gateway => "130.239.18.97",
      },
      :external_ipv6 => {
        :interface => "enp3s0f0",
        :role => :external,
        :family => :inet6,
        :address => "2001:6b0:e:2a18::114",
        :prefix => "64",
        :gateway => "fe80::5a97:bdff:fe79:dbc0",
      },
    },
  },
  :squid => {
    :cache_mem => "28000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "sweden.render.openstreetmap.org",
    :tile_siblings => [
      "nidhogg.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "rimfaxe.openstreetmap.org",
      "trogdor.openstreetmap.org",
    ],
  }
)

run_list(
  "role[umu]",
  "role[tilecache]"
)
