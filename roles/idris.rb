name "idris"
description "Master role applied to idris"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.6"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :external => {
        :interface => "bond0.101",
        :role => :external,
        :inet => {
          :address => "184.104.226.102"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::6"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[hp-g9]",
  "role[chef-server]",
  "role[chef-repository]",
  "role[dns]",
  "role[git]",
  "role[letsencrypt]",
  "role[oxidized]",
  "role[supybot]",
  "role[apt]",
  "recipe[serverinfo]"
)
