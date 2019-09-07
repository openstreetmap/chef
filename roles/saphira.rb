name "saphira"
description "Master role applied to saphira"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "185.73.44.30",
        :prefix => "22",
        :gateway => "185.73.44.1",
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:ba8:0:2c1e::",
        :prefix => "64",
        :gateway => "fe80::fcff:ffff:feff:ffff",
      },
    },
  },
  :squid => {
    :cache_mem => "5120 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "london.render.openstreetmap.org",
    :tile_siblings => [
      "toothless.openstreetmap.org",
      "trogdor.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org",
    ],
  }
)

run_list(
  "role[jump]",
  "role[geodns]",
  "role[tilecache]"
)
