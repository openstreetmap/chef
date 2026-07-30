name "faffy"
description "Master role applied to faffy"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.3"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.131"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::3"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.99"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::3"
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams-public]",
  "role[dev]"
)
