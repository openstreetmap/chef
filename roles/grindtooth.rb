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
      }
    }
  }
)

run_list(
  "role[ucl-internal]"
)
