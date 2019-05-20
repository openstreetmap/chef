name "fume"
description "Master role applied to fume"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "147.228.60.16",
        :prefix => "24",
        :gateway => "147.228.60.1"
      }
    }
  },
  :squid => {
    :cache_mem => "4096 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "pilsen.render.openstreetmap.org",
    :tile_siblings => [
      "sarkany.openstreetmap.org",
      "chrysophylax.openstreetmap.org",
      "drogon.openstreetmap.org",
      "viserion.openstreetmap.org"
    ]
  }
)

run_list(
  "role[zcu]",
  "role[tilecache]"
)
