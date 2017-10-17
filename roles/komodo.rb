name "komodo"
description "Master role applied to komodo"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp0s3",
        :role => :external,
        :family => :inet,
        :address => "103.253.107.131",
        :prefix => "24",
        :gateway => "103.253.107.1"
      }
    }
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "indonesia.render.openstreetmap.org",
    :tile_siblings => [
      "longma.openstreetmap.org"
    ]
  }
)

run_list(
  "role[g5solutions]",
  "role[geodns]",
  "role[tilecache]"
)
