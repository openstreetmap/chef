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
    :version => 4,
    :cache_mem => "4096 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 50000 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 15000 slot-size=8192 max-size=8092",
      "rock /store/squid/rock-16384 25000 slot-size=16384 max-size=16284",
      "rock /store/squid/rock-32768 35000 slot-size=32768 max-size=262144"
    ]
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
