name "norbert"
description "Master role applied to norbert"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.17"
        },
        :bond => {
          :slaves => %w[enp25s0f0 enp25s0f1]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.145"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::11"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.113"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::11"
        }
      }
    }
  },
  :planet => {
    :replication => "enabled"
  }
)

run_list(
  "role[equinix-ams]",
  "role[geodns]",
  "role[backup]",
  "role[planet]",
  "role[planetdump]",
  "recipe[tilelog]"
)
