name "viserion"
description "Master role applied to viserion"

default_attributes(
  :accounts => {
    :users => {
      :anovak => { :status => :administrator }
    }
  },
  :location => "Pula, Croatia",
  :munin => {
    :allow => ["193.198.233.210"]
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "193.198.233.211",
        :prefix => "29",
        :gateway => "193.198.233.209"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:b68:4cff:3::3",
        :prefix => "64",
        :gateway => "2001:b68:4cff:3::1"
      }
    },
    :nameservers => [
      "161.53.2.66",
      "2001:b68:ff:1::2",
      "2001:b68:ff:2::2",
      "2001:4860:4860::8888"
    ]
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "pula.render.openstreetmap.org",
    :tile_siblings => [
      "drogon.openstreetmap.org"
    ]
  }
)

run_list(
  "role[carnet]",
  "role[tilecache]"
)
