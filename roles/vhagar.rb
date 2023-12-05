name "vhagar"
description "Master role applied to vhagar"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.5"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.133"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::5"
        }
      }
    }
  },
  :nominatim => {
    :state => "standalone",
    :dbcluster => "15/main",
    :flatnode_file => "/srv/nominatim.openstreetmap.org/planet-project/nodes.store",
    :api_flavour => "python",
    :api_workers => 24,
    :api_pool_size => 8
  }
)

run_list(
  "role[equinix-ams]",
  "role[nominatim]"
)
