name "spike-06"
description "Master role applied to spike-06"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.6"
        },
        :bond => {
          :slaves => %w[eno1 eno2]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.134"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::6"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.102"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::6"
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams-public]",
  "role[hp-g9]",
  "role[web-frontend]",
  "role[web-statistics]",
  "role[web-cleanup]"
)
