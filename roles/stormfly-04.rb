name "stormfly-04"
description "Master role applied to stormfly-04"

default_attributes(
  :hardware => {
    :shm_size => "38g"
  },
  :networking => {
    :interfaces => {
      :external => {
        :interface => "bond0",
        :role => :external,
        :inet => {
          :address => "140.211.167.100"
        },
        :inet6 => {
          :address => "2605:bc80:3010:700::8cd3:a764"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      }
    }
  },
  :postgresql => {
    :versions => ["15"],
    :settings => {
      :defaults => {
        :work_mem => "300MB",
        :fsync => "on",
        :effective_io_concurrency => "100"
      }
    }
  },
  :nominatim => {
    :state => "standalone",
    :dbcluster => "15/main",
    :postgis => "3",
    :flatnode_file => "/srv/nominatim.openstreetmap.org/planet-project/nodes.store",
    :api_flavour => "python",
    :api_workers => 19,
    :api_pool_size => 7
  }
)

run_list(
  "role[osuosl]",
  "role[hp-g9]",
  "role[geodns]",
  "role[nominatim]"
)
