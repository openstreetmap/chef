name "spike-07"
description "Master role applied to spike-07"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.7"
        },
        :bond => {
          :slaves => %w[eno1 eno2]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.135"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::7"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.103"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::7"
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams-public]",
  "role[hp-g9]",
  "role[web-frontend]"
)
