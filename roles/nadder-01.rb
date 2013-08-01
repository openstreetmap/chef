name "nadder-01"
description "Master role applied to nadder-01"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "192.163.219.36",
        :prefix => "19",
        :gateway => "192.163.192.1"
      }
    }
  },
  :squid => {
    :cache_mem => "1500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  }
)

run_list(
  "role[bluehost]",
  "role[tilecache]"
)
