name "nidhogg"
description "Master role applied to nidhogg"

default_attributes(
  :networking => {
    :netplan => true,
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "130.236.254.221",
        :prefix => "24",
        :gateway => "130.236.254.1"
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2001:6b0:17:f0a0::dd",
        :prefix => "64",
        :gateway => "2001:6b0:17:f0a0::1"
      }
    }
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "sweden.render.openstreetmap.org",
    :tile_siblings => [
      "fafnir.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "rimfaxe.openstreetmap.org",
      "trogdor.openstreetmap.org"
    ]
  }
)

run_list(
  "role[lysator]",
  "role[tilecache]"
)
