name "stormfly-03"
description "Master role applied to stormfly-03"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "bond0",
        :role => :external,
        :inet => {
          :address => "140.211.167.99"
        },
        :inet6 => {
          :address => "2605:bc80:3010:700::8cd3:a763"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      }
    },
    :private_address => "10.0.16.200"
  }
)

run_list(
  "role[osuosl]",
  "role[hp-g9]",
  "role[prometheus]"
)
