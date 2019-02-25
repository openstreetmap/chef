name "tuatara"
description "Master role applied to tuatara"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "103.106.66.202",
        :prefix => "24",
        :gateway => "103.106.66.254"
      }
    }
  },
  :squid => {
    :cache_mem => "75000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "wellington.render.openstreetmap.org",
    :tile_siblings => [
      "longma.openstreetmap.org",
      "storfly-02.openstreetmap.org",
      "jakelong.openstreetmap.org"
    ]
  }
)

run_list(
  "role[hostedinnz]",
  "role[tilecache]"
)
