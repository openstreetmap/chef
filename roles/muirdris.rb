name "muirdris"
description "Master role applied to muirdris"

default_attributes(
  :memcached => {
    :memory_limit => 128 * 1024
  },
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.15"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :external => {
        :interface => "bond0.101",
        :role => :external,
        :inet => {
          :address => "184.104.226.111"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::f"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[gps-tile]"
)
