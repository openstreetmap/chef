name "quetzal"
description "Master role applied to quetzal"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.11"
        },
        :bond => {
          :slaves => %w[ens10f0np0 ens10f1np1]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.107"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::b"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.107"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::b"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub-public]"
)
