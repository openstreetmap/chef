name "rhaegal"
description "Master role applied to rhaegal"

default_attributes(
  :accounts => {
    :users => {
      :mmiler => { :status => :administrator }
    }
  },
  :location => "Zagreb, Croatia",
  :munin => {
    :plugins => {
      :sensors_temp => {
        :temp1 => { :warning => "85.0" },
        :temp2 => { :warning => "85.0" },
        :temp3 => { :warning => "85.0" },
        :temp4 => { :warning => "85.0" },
        :temp5 => { :warning => "85.0" },
        :temp6 => { :warning => "85.0" },
        :temp8 => { :warning => "85.0" },
        :temp9 => { :warning => "85.0" },
        :temp10 => { :warning => "85.0" },
        :temp11 => { :warning => "85.0" },
        :temp12 => { :warning => "85.0" },
        :temp13 => { :warning => "85.0" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "10.5.0.77",
        :prefix => "16",
        :gateway => "10.5.0.1",
        :public_address => "161.53.248.77"
      }
    }
  }
)

run_list(
  "role[carnet]"
)
