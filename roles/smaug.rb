name "smaug"
description "Master role applied to smaug"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.14"
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
          :address => "184.104.226.110"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::e"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[matomo]"
)
