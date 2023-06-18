name "gorwen"
description "Master role applied to gorwen"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.11"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 ens1f0 ens1f1]
        }
      },
      :external => {
        :interface => "bond0.101",
        :role => :external,
        :inet => {
          :address => "184.104.226.107"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::b"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[hp-dl360e-g8]",
  "role[overpass-query]"
)
