name "odin"
description "Master role applied to odin"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "130.225.254.123",
        :prefix => "23",
        :gateway => "130.225.254.97",
        :bond => {
          :mode => "802.3ad",
          :miimon => "100",
          :xmithashpolicy => "layer3+4",
          :lacprate => "fast",
          :slaves => %w[eno1 eno2]
        }
      },
      :external_ipv6 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet6,
        :address => "2001:878:346::123",
        :prefix => "64",
        :gateway => "2001:878:346::97"
      }
    }
  },
  :squid => {
    :cache_mem => "14000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "aalborg.render.openstreetmap.org",
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
  "role[dotsrc]",
  "role[tilecache]"
)
