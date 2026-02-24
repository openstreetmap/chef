name "muirdris"
description "Master role applied to muirdris"

default_attributes(
  :accounts => {
    :users => {
      :yuri => { :status => :user }
    }
  },
  :chef => {
    :client => {
      :cinc => true
    }
  },
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.15"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.111"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::f"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.111"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::f"
        }
      }
    }
  },
  :wiki => {
    :site_name => "test.wiki.openstreetmap.org",
    :site_aliases => [],
    :site_notice => "TEST INSTANCE: Use wiki.openstreetmap.org for real work",
    :test_mode => true
  }
)

override_attributes(
  :memcached => {
    :memory_limit => 128 * 1024
  }
)

run_list(
  "role[equinix-dub-public]",
  "role[gps-tile]",
  "role[wiki]"
)
