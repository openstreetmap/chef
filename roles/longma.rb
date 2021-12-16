name "longma"
description "Master role applied to longma"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.64.13",
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[enp68s0f0 enp68s0f1 enp68s0f2 enp68s0f3]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.101",
        :role => :external,
        :family => :inet,
        :address => "184.104.226.109"
      },
      :external_ipv6 => {
        :interface => "bond0.101",
        :role => :external,
        :family => :inet6,
        :address => "2001:470:1:b3b::d"
      }
    }
  },
  :postgresql => {
    :versions => ["14"],
    :settings => {
      :defaults => {
        :max_connections => "550",
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
    :enable_qa_tiles => true,
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :logdir => "/ssd/nominatim/log",
    :fpm_pools => {
      "nominatim.openstreetmap.org" => {
        :max_children => 200
      }
    }
  }
)

run_list(
  "role[equinix-dub]",
  "role[nominatim]"
)
