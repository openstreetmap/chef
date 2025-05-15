name "dribble"
description "Master role applied to dribble"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.4"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.132"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::4"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.100"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::4"
        }
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :effective_cache_size => "350GB"
      }
    }
  },
  :vectortile => {
    :replication => {
      :tileupdate => false
    }
  }
)

run_list(
  "role[equinix-ams-public]",
  "role[vectortile]"
)
