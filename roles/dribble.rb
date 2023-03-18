name "dribble"
description "Master role applied to dribble"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.4"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :external => {
        :interface => "bond0.2",
        :role => :external,
        :inet => {
          :address => "130.117.76.4"
        },
        :inet6 => {
          :address => "2001:978:2:2c::172:4"
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams]"
)
