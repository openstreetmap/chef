name "norbert"
description "Master role applied to norbert"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.17"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[enp25s0f0 enp25s0f1]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.145"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::11"
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
