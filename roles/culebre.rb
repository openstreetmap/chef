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
        :gateway => "155.210.4.110"
      },
      :internal_ipv4 => {
        :interface => "ens4",
        :role => :internal,
        :family => :inet,
        :address => "10.148.97.151",
        :prefix => "24"
      }
    }
  },
  :squid => {
    :version => "3",
    :cache_mem => "6100 MB",
    :cache_dir => "rock /store/squid/rock-01 80000 swap-timeout=500 max-swap-rate=150 slot-size=4096 max-size=262144"
  },
  :tilecache => {
    :tile_parent => "zaragoza.render.openstreetmap.org",
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
  "role[unizar]",
  "role[tilecache]"
)
