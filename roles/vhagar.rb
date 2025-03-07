name "vhagar"
description "Master role applied to vhagar"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.5"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.133"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::5"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.101"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::5"
        }
      }
    }
  },
  :nominatim => {
    :dbcluster => "17/main",
    :flatnode_file => "/srv/nominatim.openstreetmap.org/planet-project/nodes.store",
    :api_flavour => "python",
    :api_workers => 24,
    :api_pool_size => 8
  }
)

run_list(
  "role[equinix-ams-public]",
  "role[nominatim]"
)
