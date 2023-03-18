name "tabaluga"
description "Master role applied to tabaluga"

default_attributes(
  :dhcpd => {
    :first_address => "10.0.62.1",
    :last_address => "10.0.62.254"
  },
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
        :interface => "bond0.2",
        :role => :external,
        :inet => {
          :address => "130.117.76.14"
        },
        :inet6 => {
          :address => "2001:978:2:2c::172:e"
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[hp-g9]",
  "recipe[dhcpd]"
)
