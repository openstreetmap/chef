name "spike-03"
description "Master role applied to spike-03"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :role => :internal,
        :inet => {
          :address => "10.0.64.5"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.101"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::5"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.101"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::5"
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
