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
      :external => {
        :interface => "bond0.101",
        :role => :external,
        :inet => {
          :address => "184.104.226.109"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::d"
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
