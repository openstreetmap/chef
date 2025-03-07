name "spike-08"
description "Master role applied to spike-08"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.8"
        },
        :bond => {
          :slaves => %w[eno1 eno2]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.136"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::8"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.104"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::8"
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
