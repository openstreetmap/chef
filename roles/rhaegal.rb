name "rhaegal"
description "Master role applied to rhaegal"

default_attributes(
  :accounts => {
    :users => {
      :mmiler => { :status => :administrator }
    }
  },
  :location => "Zagreb, Croatia",
  :networking => {
    :interfaces => {
      :external => {
        :interface => "eno1",
        :role => :external,
        :inet => {
          :address => "193.198.233.218",
          :prefix => "29",
          :gateway => "193.198.233.217"
        },
        :inet6 => {
          :address => "2001:b68:40ff:3::2",
          :prefix => "64",
          :gateway => "2001:b68:40ff:3::1"
        }
      }
    }
  }
)

run_list(
  "role[carnet]"
)
