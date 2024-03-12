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
          :address => "10.5.0.77",
          :prefix => "16",
          :gateway => "10.5.0.1",
          :public_address => "161.53.248.77"
        }
      }
    }
  }
)

run_list(
  "role[carnet]"
)
