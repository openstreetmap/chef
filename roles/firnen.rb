name "firnen"
description "Master role applied to firnen"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "enp6s0",
        :role => :external,
        :inet => {
          :address => "188.241.28.82",
          :prefix => "29",
          :gateway => "188.241.28.81"
        }
      }
    }
  }
)

run_list(
  "role[epix]"
)
