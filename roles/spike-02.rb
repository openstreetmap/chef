name "spike-02"
description "Master role applied to spike-02"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.4"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.100"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::4"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.100"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::4"
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
