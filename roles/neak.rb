name "neak"
description "Master role applied to neak"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "89.234.177.142",
        :prefix => "26",
        :gateway => "89.234.177.129"
      }
    }
  }
)

run_list(
  "role[faimaison]"
)
