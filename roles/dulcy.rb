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
          :slaves => %w[enp1s0f0 enp1s0f1]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.137"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::9"
        }
      }
    }
  },
  :postgresql => {
    :versions => ["17"],
    :settings => {
      :defaults => {
        :work_mem => "240MB",
        :effective_io_concurrency => "500"
      }
    }
  },
  :nominatim => {
    :dbcluster => "17/main",
    :flatnode_file => "/srv/nominatim.openstreetmap.org/planet-project/nodes.store",
    :enable_qa_tiles => true,
    :api_workers => 14,
    :api_pool_size => 10
  }
)

run_list(
  "role[equinix-ams]"
  "role[nominatim]"
)
