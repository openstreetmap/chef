name "lurien"
description "Master role applied to lurien"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.64.1.22",
        :prefix => "24",
        :mtu => "9000"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "193.55.222.229",
        :prefix => "24",
        :gateway => "193.55.222.1"
      }
    }
  },
  :squid => {
    :cache_mem => "9000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "pau.render.openstreetmap.org",
    :tile_siblings => [
      "nepomuk.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "fume.openstreetmap.org",
      "gorynych.openstreetmap.org"
    ]
  }
)

run_list(
  "role[paulla]",
  "role[tilecache]"
)
