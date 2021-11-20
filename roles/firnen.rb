name "firnen"
description "Master role applied to firnen"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp6s0",
        :role => :external,
        :family => :inet,
        :address => "188.241.28.82",
        :prefix => "29",
        :gateway => "188.241.28.81"
      }
    }
  }
)

run_list(
  "role[epix]"
)
