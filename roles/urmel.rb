name "urmel"
description "Master role applied to urmel"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.6"
      },
      :external_ipv4 => {
        :interface => "eth1.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.21"
      }
    }
  }
)

run_list(
  "role[ucl-slough]",
  "role[hp-dl360-g6]",
  "role[munin]"
)
