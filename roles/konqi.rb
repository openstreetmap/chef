name "konqi"
description "Master role applied to konqi"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.7"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.103"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::7"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.103"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::7"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub-public]",
  "role[hp-g9]",
  "role[wiki]"
)
