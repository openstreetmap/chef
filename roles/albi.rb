name "albi"
description "Master role applied to albi"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp1s0f0",
        :role => :external,
        :family => :inet,
        :address => "51.159.53.238",
        :prefix => "24",
        :gateway => "51.159.53.1"
      },
      :external_ipv6 => {
        :interface => "enp1s0f0",
        :role => :external,
        :family => :inet6,
        :address => "2001:bc8:1200:4:dac4:97ff:fe8a:9cfc",
        :prefix => "64",
        :gateway => "fe80::a293:51ff:fea2:ded5"
      }
    }
  }
)

run_list(
  "role[scaleway]"
)
