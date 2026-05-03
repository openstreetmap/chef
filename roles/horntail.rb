name "horntail"
description "Master role applied to horntail"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.10"
        },
        :bond => {
          :slaves => %w[enp25s0f0np0 enp25s0f1np1]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.106"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::a"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.106"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::a"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub-public]",
  "role[geodns]",
  "role[planet]"
)
