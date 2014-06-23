name "grindtooth"
description "Master role applied to grindtooth"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.19"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.100"
      }
    }
  }
)

run_list(
  "role[ucl-wates]",
  "role[taginfo]"
)
