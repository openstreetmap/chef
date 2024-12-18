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
      :external_he => {
        :interface => "bond0.101",
        :role => :external,
        :source_route_table => 100,
        :inet => {
          :address => "184.104.226.106",
          :prefix => "27",
          :gateway => "184.104.226.97"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::a",
          :prefix => 64,
          :gateway => "2001:470:1:b3b::1"
        }
      },
      :external => {
        :interface => "bond0.203",
        :role => :external,
        :metric => 150,
        :source_route_table => 150,
        :inet => {
          :address => "87.252.214.106",
          :prefix => "27",
          :gateway => "87.252.214.97"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::a",
          :prefix => 64,
          :gateway => "2001:4d78:fe03:1c::1"
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
