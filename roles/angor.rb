name "angor"
description "Master role applied to angor"

default_attributes(
  :hardware => {
    :shm_size => "18g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "196.10.54.165",
        :prefix => "29",
        :gateway => "196.10.54.161"
      },
      :external_ipv6 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet6,
        :address => "2001:43f8:1f4:b00:b283:feff:fed8:dd45",
        :prefix => "64",
        :gateway => "2001:43f8:1f4:b00::1"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "16384 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 12800 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 16000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 22400 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 22800 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "capetown.render.openstreetmap.org"
  }
)

run_list(
  "role[inxza]",
  "role[tilecache]",
  "role[ftp]"
)
