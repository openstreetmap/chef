name "dulcy"
description "Master role applied to dulcy"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.9",
        :bond => {
          :slaves => %w[ens18f0 ens18f1]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet,
        :address => "130.117.76.9"
      },
      :external_ipv6 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet6,
        :address => "2001:978:2:2C::172:9"
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
    :logdir => "/ssd/nominatim/log"
  }
)

run_list(
  "role[equinix-ams]",
  "role[nominatim]"
)
