name "drogon"
description "Master role applied to drogon"

default_attributes(
  :accounts => {
    :users => {
      :zelja => { :status => :administrator }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "161.53.30.107",
        :prefix => "27",
        :gateway => "161.53.30.97"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:b68:c0ff:0:221:5eff:fe40:c7c4",
        :prefix => "64",
        :gateway => "fe80::161:53:30:97"
      }
    },
    :nameservers => [
      "161.53.30.100",
      "8.8.8.8"
    ]
  },
  :squid => {
    :cache_mem => "4000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "pula.render.openstreetmap.org",
    :tile_siblings => [
      "viserion.openstreetmap.org"
    ]
  }
)

run_list(
  "role[carnet]",
  "role[tilecache]"
)
