name "chrysophylax"
description "Master role applied to chrysophylax"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet,
        :address => "217.71.244.22",
        :prefix => "30",
        :gateway => "217.71.244.21"
      },
      :external_ipv6 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet6,
        :address => "2001:8e0:40:2039::10",
        :prefix => "64",
        :gateway => "2001:8e0:40:2039::1"
      }
    }
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "zurich.render.openstreetmap.org",
    :tile_siblings => [
      "noomoahk.openstreetmap.org",
      "ladon.openstreetmap.org",
      "culebre.openstreetmap.org"
    ]
  }
)

run_list(
  "role[iway]",
  "role[geodns]",
  "role[tilecache]"
)
