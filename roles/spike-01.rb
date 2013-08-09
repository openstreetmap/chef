name "spike-01"
description "Master role applied to spike-01"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.162"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.99"
      },
      :external_ipv6 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:21a:4bff:fea5:fd2a"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[web-frontend]",
  "role[web-gpximport]",
  "role[web-statistics]",
  "role[web-cleanup]"
)
