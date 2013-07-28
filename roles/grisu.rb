name "grisu"
description "Master role applied to grisu"

default_attributes(
  :accounts => {
    :users => {
      :yellowbkpk => { :status => :administrator }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "142.4.213.166",
        :prefix => "24",
        :gateway => "142.4.213.254"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2607:5300:60:12a6::1",
        :prefix => "64",
        :gateway => "2607:5300:60:12ff:ff:ff:ff:ff"
      }
    }
  },
  :squid => {
    :cache_mem => "9000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  }
)

run_list(
  "role[ovh-ca]",
  "role[tilecache]"
)
