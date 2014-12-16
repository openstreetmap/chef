name "stormfly-02"
description "Master role applied to stormfly-02"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "em1",
        :role => :external,
        :family => :inet,
        :address => "140.211.167.105"
      }
    }
  },
  :squid => {
    :cache_mem => "32000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "corvallis.render.openstreetmap.org",
    :tile_siblings => [
      "nadder-01.openstreetmap.org",
      "nadder-02.openstreetmap.org",
      "jakelong.openstreetmap.org",
      "nepomuk.openstreetmap.org",
      "lurien.openstreetmap.org"
    ]
  }
)

run_list(
  "role[osuosl]",
  "role[hp-g6]",
  "role[tilecache]"
)
