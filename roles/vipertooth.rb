name "vipertooth"
description "Master role applied to vipertooth"

default_attributes(
  :location => "Kiev, Ukraine",
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet,
        :address => "176.122.99.101",
        :prefix => "26",
        :gateway => "176.122.99.126",
      },
      :external_ipv6 => {
        :interface => "ens160",
        :role => :external,
        :family => :inet6,
        :address => "2001:67c:2d40::65",
        :prefix => "64",
        :gateway => "2001:67c:2d40::fffe",
      },
    },
  },
  :squid => {
    :cache_mem => "16000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "kiev.render.openstreetmap.org",
    :tile_siblings => [
      "cmok.openstreetmap.org",
      "sarkany.openstreetmap.org",
      "kalessin.openstreetmap.org",
      "konqi.openstreetmap.org",
    ],
  }
)

run_list(
  "role[utelecom]",
  "role[tilecache]"
)
