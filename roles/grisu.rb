name "grisu"
description "Master role applied to grisu"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.17"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.113"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::11"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.113"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::11"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub-public]",
  "role[overpass-query]"
)
