name "jakelong"
description "Master role applied to jakelong"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "64.62.205.202",
        :prefix => "26",
        :gateway => "64.62.205.193"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:470:1:41:a800:ff:fe3e:cdca",
        :prefix => "64",
        :gateway => "fe80::21b:21ff:fead:e886"
      }
    }
  },
  :squid => {
    :cache_mem => "650 MB",
    :cache_dir => "coss /store/squid/coss-01 15000 block-size=8192 max-size=262144 membufs=30"
  },
  :tilecache => {
    :tile_parent => "sanfrancisco.render.openstreetmap.org",
    :tile_siblings => [
      "nadder-01.openstreetmap.org",
      "nadder-02.openstreetmap.org"
    ]
  }
)

run_list(
  "role[prgmr]",
  "role[tilecache]"
)
