name "jakelong"
description "Master role applied to jakelong"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "64.62.205.202",
        :prefix => "26",
        :gateway => "64.62.205.193"
      }
    }
  },
  :squid => {
    :cache_mem => "650 MB",
    :cache_dir => "coss /store/squid/coss-01 15000 block-size=8192 max-size=262144 membufs=30"
  }
)

run_list(
  "role[prgmr]",
  "role[tilecache]"
)
