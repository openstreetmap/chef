name "poldi"
description "Master role applied to poldi"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :inet => {
          :address => "140.211.167.102"
        },
        :inet6 => {
          :address => "2605:bc80:3010:700::8cd3:a766"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      }
    }
  }
)

run_list(
  "role[osuosl]"
)
