name "spike-07"
description "Master role applied to spike-07"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.12"
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
          :address => "130.117.76.12",
          :prefix => "27",
          :gateway => "130.117.76.1"
        },
        :inet6 => {
          :address => "2001:978:2:2c::172:c",
          :prefix => "64",
          :gateway => "2001:978:2:2c::172:1",
          :routes => {
            "2001:470:1:b3b::/64" => { :type => "unreachable" }
          }
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[hp-g9]",
  "role[web-frontend]"
)
