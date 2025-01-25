name "naga"
description "Master role applied to naga"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.8"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :external_he => {
        :interface => "bond0.101",
        :role => :external,
        :source_route_table => 100,
        :inet => {
          :address => "184.104.226.104",
          :prefix => "27",
          :gateway => "184.104.226.97"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::8",
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
          :address => "87.252.214.104",
          :prefix => "27",
          :gateway => "87.252.214.97"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::8",
          :prefix => 64,
          :gateway => "2001:4d78:fe03:1c::1"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[hp-g9]",
  "role[subversion]",
  "role[trac]",
  "role[irc]",
  "role[blogs]",
  "role[switch2osm]",
  "recipe[foundation::birthday]",
  "recipe[foundation::mastodon]",
  "recipe[foundation::owg]",
  "recipe[foundation::welcome]",
  "recipe[stateofthemap::container]",
  "recipe[hot]",
  "recipe[ideditor]",
  "recipe[dmca]",
  "role[otrs]"
)
