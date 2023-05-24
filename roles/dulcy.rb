name "dulcy"
description "Master role applied to dulcy"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.9"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[ens18f0 ens18f1]
        }
      },
      :external_cogent => {
        :interface => "bond0.2",
        :role => :external,
        :source_route_table => 100,
        :inet => {
          :address => "130.117.76.9",
          :prefix => "27",
          :gateway => "130.117.76.1"
        },
        :inet6 => {
          :address => "2001:978:2:2c::172:9",
          :prefix => "64",
          :gateway => "2001:978:2:2c::172:1",
          :routes => {
            "2001:470:1:b3b::/64" => { :type => "unreachable" }
          }
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :metric => 150,
        :source_route_table => 150,
        :inet => {
          :address => "184.104.179.137",
          :prefix => "27",
          :gateway => "184.104.179.129"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::9",
          :prefix => "64",
          :gateway => "2001:470:1:fa1::1"
        }
      }
    }
  },
  :postgresql => {
    :versions => ["14"],
    :settings => {
      :defaults => {
        :work_mem => "240MB",
        :fsync => "on",
        :effective_io_concurrency => "500"
      }
    }
  },
  :nominatim => {
    :state => "standalone",
    :dbcluster => "14/main",
    :postgis => "3",
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :logdir => "/ssd/nominatim/log",
    :config => {
      :forward_dependencies => "yes"
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[nominatim]"
)
