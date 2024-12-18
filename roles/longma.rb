name "longma"
description "Master role applied to longma"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.13"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[enp68s0f0np0 enp68s0f1np1 enp68s0f2np2 enp68s0f3np3]
        }
      },
      :external_he => {
        :interface => "bond0.101",
        :role => :external,
        :source_route_table => 100,
        :inet => {
          :address => "184.104.226.109",
          :prefix => "27",
          :gateway => "184.104.226.97"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::d",
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
          :address => "87.252.214.109",
          :prefix => "27",
          :gateway => "87.252.214.97"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::d",
          :prefix => 64,
          :gateway => "2001:4d78:fe03:1c::1"
        }
      }
    }
  },
  :postgresql => {
    :versions => ["17"],
    :settings => {
      :defaults => {
        :max_connections => "550",
        :work_mem => "240MB",
        :effective_io_concurrency => "500"
      }
    }
  },
  :nominatim => {
    :dbcluster => "17/main",
    :enable_qa_tiles => true,
    :flatnode_file => "/srv/nominatim.openstreetmap.org/planet-project/nodes.store",
    :api_workers => 24,
    :api_pool_size => 10
  }
)

run_list(
  "role[equinix-dub]",
  "role[nominatim]"
)
