name "ridgeback"
description "Master role applied to ridgeback"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "31.169.50.10",
        :prefix => "30",
        :gateway => "31.169.50.9"
      }
    }
  },
  :squid => {
    :cache_mem => "5500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  }
)

run_list(
  "role[blix-no]",
  "role[tilecache]"
)
