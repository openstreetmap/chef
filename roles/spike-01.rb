name "spike-01"
description "Master role applied to spike-01"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.99",
        :hwaddress => "00:1a:4b:a5:fd:2a"
      },
      :external_ipv6 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:21a:4bff:fea5:fd2a",
        :hwaddress => "00:1a:4b:a5:fd:2a"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[hp-g6]",
  "role[web-frontend]",
  "role[web-gpximport]",
  "role[web-statistics]",
  "role[web-cleanup]"
)
