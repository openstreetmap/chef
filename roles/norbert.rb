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
        :interface => "bond0.2",
        :role => :external,
        :inet => {
          :address => "130.117.76.17"
        },
        :inet6 => {
          :address => "2001:978:2:2c::172:11"
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
