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
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.134"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::6"
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
