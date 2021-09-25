name "idris"
description "Master role applied to idris"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.64.6",
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :slaves => %w[eno1 eno2]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.101",
        :role => :external,
        :family => :inet,
        :address => "184.104.226.102"
      },
      :external_ipv6 => {
        :interface => "bond0.101",
        :role => :external,
        :family => :inet6,
        :address => "2001:470:1:b3b::6"
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[hp-g9]"
)
