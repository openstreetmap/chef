name "katie"
description "Master role applied to katie"

default_attributes(
  :devices => {
    :disktune => {
      :comment => "Tune scheduler for Toshiba disks",
      :type => "block",
      :bus => "ata",
      :serial => "TOSHIBA_DT01ACA300_*",
      :attrs => {
        "queue/scheduler" => "deadline",
      },
    },
  },
  :location => "Falkenstein, Germany",
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "144.76.70.77",
        :prefix => "27",
        :gateway => "144.76.70.65",
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2a01:4f8:191:834c::2",
        :prefix => "64",
        :gateway => "fe80::1",
      },
    },
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80",
  },
  :tilecache => {
    :tile_parent => "germany.render.openstreetmap.org",
    :tile_siblings => [
      "kalessin.openstreetmap.org",
      "konqi.openstreetmap.org",
      "keizer.openstreetmap.org",
    ],
  }
)

run_list(
  "role[hetzner]",
  "role[geodns]",
  "role[tilecache]"
)
