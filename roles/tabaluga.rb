name "tabaluga"
description "Master role applied to tabaluga"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.14"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.142"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::e"
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[hp-g9]"
)
