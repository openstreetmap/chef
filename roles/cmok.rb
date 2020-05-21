name "cmok"
description "Master role applied to cmok"

default_attributes(
  :hardware => {
    :shm_size => "6g"
  },
  :munin => {
    :plugins => {
      "diskstats_latency.sdd" => {
        :avgrdwait => { :warning => "0:30" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp4s0",
        :role => :external,
        :family => :inet,
        :address => "31.130.201.40",
        :prefix => "27",
        :gateway => "31.130.201.33"
      },
      :external_ipv6 => {
        :interface => "enp4s0",
        :role => :external,
        :family => :inet6,
        :address => "2001:67c:2268:1005:21e:8cff:fe8c:8d3b",
        :prefix => "64",
        :gateway => "fe80::20c:42ff:feb2:8ff8"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "4096 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 12800 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 16000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 22400 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 22800 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :tilecache => {
    :tile_parent => "minsk.render.openstreetmap.org"
  }
)

run_list(
  "role[datahata]",
  "role[tilecache]"
)
