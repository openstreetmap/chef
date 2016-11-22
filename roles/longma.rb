name "longma"
description "Master role applied to longma"

default_attributes(
  :exim => {
    :aliases => {
      :root => "ceasar"
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "140.110.240.7",
        :prefix => "24",
        :gateway => "140.110.240.254"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:e10:2000:240::7",
        :prefix => "64",
        :gateway => "2001:e10:2000:240::254"
      }
    }
  },
  :squid => {
    :cache_mem => "12500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "hsinchu.render.openstreetmap.org"
  }
)

run_list(
  "role[nchc]",
  "role[tilecache]"
)
