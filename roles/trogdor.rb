name "trogdor"
description "Master role applied to trogdor"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "134.90.146.26",
        :prefix => "30",
        :gateway => "134.90.146.25"
      }
    }
  },
  :squid => {
    :cache_mem => "6400 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "orm.openstreetmap.org"
  }
)

run_list(
  "role[blix-nl]",
  "role[tilecache]"
)
