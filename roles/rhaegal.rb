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
        }
      }
    }
  }
)

run_list(
  "role[carnet]"
)
