name "spike-06"
description "Master role applied to spike-06"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.6"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2]
        }
      },
      :external_he => {
        :interface => "bond0.3",
        :role => :external,
        :metric => 150,
        :source_route_table => 100,
        :inet => {
          :address => "184.104.179.134",
          :prefix => "27",
          :gateway => "184.104.179.129"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::6",
          :prefix => 64,
          :gateway => "2001:470:1:fa1::1"
        }
      },
      :external => {
        :interface => "bond0.103",
        :role => :external,
        :source_route_table => 150,
        :inet => {
          :address => "82.199.86.102",
          :prefix => "27",
          :gateway => "82.199.86.97"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::6",
          :prefix => 64,
          :gateway => "2001:4d78:500:5e3::1"
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[hp-g9]",
  "role[web-frontend]",
  "role[web-statistics]",
  "role[web-cleanup]"
)
