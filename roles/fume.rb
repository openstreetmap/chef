name "fume"
description "Master role applied to fume"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.16"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.112"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::10"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.112"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::10"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub-public]",
  "role[community]"
)
