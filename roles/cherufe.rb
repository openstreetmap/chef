name "cherufe"
description "Master role applied to cherufe"

default_attributes(
  :hardware => {
    :shm_size => "12g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "200.91.44.37",
        :prefix => "23",
        :gateway => "200.91.44.1"
      }
    }
  },
  :openssh => {
    :port => 45222
  },
  :squid => {
    :version => 4,
    :cache_mem => "8192 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :nginx => {
    :cache => {
      :proxy => {
        :max_size => "8192M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "vinadelmar.render.openstreetmap.org"
  }
)

run_list(
  "role[altavoz]",
  "role[tilecache]"
)
