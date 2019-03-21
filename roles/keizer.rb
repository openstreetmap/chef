name "keizer"
description "Master role applied to keizer"

default_attributes(
  :location => "Nuremberg, Germany",
  :networking => {
    :netplan => true,
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "195.201.226.63",
        :prefix => "32",
        :gateway => "172.31.1.1"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2a01:4f8:1c1c:bc54::1",
        :prefix => "64",
        :gateway => "fe80::1"
      }
    }
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "germany.render.openstreetmap.org",
    :tile_siblings => [
      "katie.openstreetmap.org",
      "kalessin.openstreetmap.org",
      "konqi.openstreetmap.org"
    ]
  }
)

run_list(
  "role[hetzner]",
  "role[tilecache]"
)
