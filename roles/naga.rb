name "naga"
description "Master role applied to naga"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.8"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.104"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::8"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.104"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::8"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub-public]",
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
  "role[otrs]",
  "role[osqa]"
)
