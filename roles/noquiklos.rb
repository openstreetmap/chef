name "noquiklos"
description "Master role applied to noquiklos"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.89.121.98"
      }
    }
  }
)

run_list(
  "role[firefishynet]"
)
