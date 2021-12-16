name "stormfly-04"
description "Master role applied to stormfly-04"

default_attributes(
  :hardware => {
    :shm_size => "38g"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "140.211.167.100",
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :external_ipv6 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet6,
        :address => "2605:bc80:3010:700::8cd3:a764"
      }
    }
  },
  :postgresql => {
    :versions => ["14"],
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
    :enable_qa_tiles => true,
    :dbcluster => "14/main",
    :postgis => "3",
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :logdir => "/ssd/nominatim/log",
    :fpm_pools => {
      "nominatim.openstreetmap.org" => {
        :max_children => 100
      }
    }
  }
)

run_list(
  "role[osuosl]",
  "role[hp-g9]",
  "role[geodns]",
  "role[nominatim]"
)
