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
      :external => {
        :interface => "bond0.2",
        :role => :external,
        :inet => {
          :address => "130.117.76.9"
        },
        :inet6 => {
          :address => "2001:978:2:2c::172:9"
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
