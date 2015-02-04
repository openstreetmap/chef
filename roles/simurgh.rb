name "simurgh"
description "Master role applied to simurgh"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "94.20.20.55",
        :prefix => "24",
        :gateway => "94.20.20.1"
      }
    }
  },
  :squid => {
    :cache_mem => "6400 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "baku.render.openstreetmap.org",
    :tile_siblings => [
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "fume.openstreetmap.org",
      "nepomuk.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "trogdor.openstreetmap.org"
    ]
  }
)

run_list(
  "role[delta]",
  "role[tilecache]"
)
