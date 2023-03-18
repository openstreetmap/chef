name "horntail"
description "Master role applied to horntail"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.10"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[enp25s0f0 enp25s0f1]
        }
      },
      :external => {
        :interface => "bond0.101",
        :role => :external,
        :inet => {
          :address => "184.104.226.106"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::a"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[geodns]",
  "role[planet]"
)
