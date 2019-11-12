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
        "queue/scheduler" => "deadline"
      }
    }
  },
  :hardware => {
    :shm_size => "20g"
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
        :gateway => "144.76.70.65"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2a01:4f8:191:834c::2",
        :prefix => "64",
        :gateway => "fe80::1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "16384 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "germany.render.openstreetmap.org"
  }
)

run_list(
  "role[hetzner]",
  "role[geodns]",
  "role[tilecache]"
)
