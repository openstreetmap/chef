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
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.45.207"
      }
    }
  }
)

run_list(
  "role[ucl-wolfson]",
  "role[hp-g5]",
  "role[munin]"
)
