name "noquiklos"
description "Master role applied to noquiklos"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.13"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.99"
      }
    }
  }
)

run_list(
  "role[ucl-internal]"
)
