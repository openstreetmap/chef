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
      :external_he => {
        :interface => "bond0.3",
        :role => :external,
        :metric => 150,
        :source_route_table => 100,
        :inet => {
          :address => "184.104.179.132",
          :prefix => "27",
          :gateway => "184.104.179.129"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::4",
          :prefix => 64,
          :gateway => "2001:470:1:fa1::1"
        }
      },
      :external => {
        :interface => "bond0.103",
        :role => :external,
        :source_route_table => 150,
        :inet => {
          :address => "82.199.86.100",
          :prefix => "27",
          :gateway => "82.199.86.97"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::4",
          :prefix => 64,
          :gateway => "2001:4d78:500:5e3::1"
        }
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :effective_cache_size => "350GB"
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[vectortile]"
)
