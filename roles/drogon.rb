name "drogon"
description "Master role applied to drogon"

default_attributes(
  :accounts => {
    :users => {
      :zelja => { :status => :administrator }
    }
  },
  :location => "Osijek, Croatia",
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "161.53.30.107",
        :prefix => "27",
        :gateway => "161.53.30.97"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:b68:c0ff:0:221:5eff:fe40:c7c4",
        :prefix => "64",
        :gateway => "fe80::161:53:30:97"
      }
    }
  }
)

run_list(
  "role[carnet]"
)
