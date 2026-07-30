name "spike-01"
description "Master role applied to spike-01"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.3"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.99"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::3"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.99"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::3"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub-public]",
  "role[hp-g9]",
  "role[web-frontend]"
)
