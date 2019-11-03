name "saphira"
description "Master role applied to saphira"

default_attributes(
  :hardware => {
    :shm_size => "9g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "185.73.44.30",
        :prefix => "22",
        :gateway => "185.73.44.1"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:ba8:0:2c1e::",
        :prefix => "64",
        :gateway => "fe80::fcff:ffff:feff:ffff"
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "6144 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 12800 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 16000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 22400 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 22800 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :nginx => {
    :cache => {
      :proxy => {
        :max_size => "4096M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "london.render.openstreetmap.org",
    :tile_siblings => [
      "toothless.openstreetmap.org",
      "trogdor.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "gorynych.openstreetmap.org"
    ]
  }
)

run_list(
  "role[jump]",
  "role[geodns]",
  "role[tilecache]"
)
