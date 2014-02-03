name "clifford"
description "Master role applied to clifford"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.17"
      }
    }
  }
)

run_list(
  "role[ucl-internal]"
)
