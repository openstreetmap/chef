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
        :interface => "bond0.2",
        :role => :external,
        :inet => {
          :address => "130.117.76.5"
        },
        :inet6 => {
          :address => "2001:978:2:2c::172:5"
        }
      }
    }
  },
  :nominatim => {
    :state => "standalone",
    :flatnode_file => "/srv/nominatim.openstreetmap.org/planet-project/nodes.store",
    :fpm_pools => {
      "nominatim.openstreetmap.org" => {
        :max_children => 200
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[nominatim]"
)
