name "azure"
description "Master role applied to azure"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "204.16.246.252",
        :prefix => "29",
        :gateway => "204.16.246.249",
        :bond => {
          :mode => "802.3ad",
          :slaves => %w[ens1f0 ens1f1]
        }
      },
      :external_ipv6 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet6,
        :address => "2607:fdc0:1::52",
        :prefix => "64",
        :gateway => "2607:fdc0:1::1"
      }
    }
  },
  :squid => {
    :cache_mem => "5500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "usa.render.openstreetmap.org",
    :tile_siblings => [
      "stormfly-02.openstreetmap.org",
      "ascalon.openstreetmap.org",
      "jakelong.openstreetmap.org"
    ]
  }
)

run_list(
  "role[teraswitch]",
  "role[tilecache]"
)
