name "takhisis"
description "Master role applied to takhisis"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "31.3.110.20",
        :prefix => "24",
        :gateway => "31.3.110.1"
      },
      :external_ipv6 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet6,
        :address => "2a03:7900:111:0:31:3:110:20",
        :prefix => "64",
        :gateway => "fe80::225:90ff:fe5d:c1e1"
      }
    }
  }
)

run_list(
  "role[tuxis]"
)
