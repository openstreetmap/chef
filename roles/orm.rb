name "orm"
description "Master role applied to orm"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "bond0",
        :role => :external,
        :inet => {
          :address => "10.5.7.34",
          :prefix => "29",
          :gateway => "10.5.7.33",
          :public_address => "23.139.196.5"
        },
        :inet6 => {
          :address => "2602:f629:0:bc::2",
          :prefix => "64",
          :gateway => "2602:f629:0:bc::1"
        },
        :bond => {
          :slaves => %w[eno1 eno2]
        }
      }
    }
  }
)

run_list(
  "role[pixeldeck]"
)
