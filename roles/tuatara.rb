name "tuatara"
description "Master role applied to tuatara"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "114.23.141.203",
        :prefix => "29",
        :gateway => "114.23.141.201",
      },
    },
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "wellington.render.openstreetmap.org",
    :tile_siblings => [
      "waima.openstreetmap.org",
      "balerion.openstreetmap.org",
      "longma.openstreetmap.org",
    ],
  }
)

run_list(
  "role[hostedinnz]",
  "role[tilecache]"
)
