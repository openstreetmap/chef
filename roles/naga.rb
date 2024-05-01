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
      :external => {
        :interface => "bond0.101",
        :role => :external,
        :inet => {
          :address => "184.104.226.104"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::8"
        }
      }
    }
  },
  :otrs => {
    :site => "test.otrs.openstreetmap.org",
    :site_aliases => ["test.otrs.osm.org"],
    :database_cluster => "16/main"
  },
  :postgresql => {
    :versions => ["16"],
    :settings => {
      "16" => {
        :port => 5433
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
  "recipe[foundation::mastodon]",
  "recipe[foundation::owg]",
  "recipe[foundation::welcome]",
  "recipe[stateofthemap::container]",
  "recipe[hot]",
  "recipe[ideditor]",
  "recipe[dmca]",
  "recipe[otrs::debian]"
)
