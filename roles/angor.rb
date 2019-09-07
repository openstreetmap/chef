name "angor"
description "Master role applied to angor"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "196.10.54.165",
        :prefix => "29",
        :gateway => "196.10.54.161",
      },
      :external_ipv6 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet6,
        :address => "2001:43f8:1f4:b00:b283:feff:fed8:dd45",
        :prefix => "64",
        :gateway => "2001:43f8:1f4:b00::1",
      },
    },
  },
  :squid => {
    :cache_mem => "6100 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "capetown.render.openstreetmap.org",
    :tile_siblings => [
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org",
    ],
  }
)

run_list(
  "role[inxza]",
  "role[tilecache]",
  "role[ftp]"
)
