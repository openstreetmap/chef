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
          :slaves => %w[enp68s0f0 enp68s0f1 enp68s0f2 enp68s0f3]
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
    :versions => ["16"],
    :settings => {
      :defaults => {
        :max_connections => "550",
        :work_mem => "240MB",
        :effective_io_concurrency => "500"
      }
    }
  },
  :nominatim => {
    :state => "standalone",
    :dbcluster => "16/main",
    :postgis => "3",
    :enable_qa_tiles => true,
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :logdir => "/ssd/nominatim/log",
    :api_flavour => "python",
    :api_workers => 24,
    :api_pool_size => 10,
    :fpm_pools => {
      "nominatim.openstreetmap.org" => {
        :max_children => 200
      }
    },
    :config => {
      :forward_dependencies => "yes"
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[nominatim]"
)
