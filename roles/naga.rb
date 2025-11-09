name "naga"
description "Master role applied to naga"

default_attributes(
  :elasticsearch => {
    :version => "7.x",
    :cluster => {
      :name => "foundation"
    }
  },
  :memcached => {
    :memory_limit => 400,
    :chunk_growth_factor => 1.05,
    :min_item_size => 5
  },
  :mysql => {
    :settings => {
      :mysqld => {
        :innodb_buffer_pool_size => "512M",
        :key_buffer_size => "64M",
        :max_connections => "200",
        :sort_buffer_size => "8M",
        :tmp_table_size => "48M"
      }
    }
  },
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
  "role[elasticsearch]",
  "recipe[foundation::birthday]",
  "recipe[foundation::board]",
  "recipe[foundation::dwg]",
  "recipe[foundation::mastodon]",
  "recipe[foundation::mwg]",
  "recipe[foundation::owg]",
  "recipe[foundation::welcome]",
  "recipe[foundation::wiki]",
  "recipe[stateofthemap::container]",
  "recipe[hot]",
  "recipe[ideditor]",
  "recipe[dmca]",
  "role[otrs]",
  "role[osqa]"
)
