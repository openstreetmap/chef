name "pummelzacken"
description "Master role applied to pummelzacken"

default_attributes(
  :networking => {
    :interfaces => {
      :bond => {
        :interface => "bond0",
        :bond => {
          :slaves => %w[eno1 enp5s0f0]
        }
      },
      :internal_ipv4 => {
        :interface => "bond0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.20"
      },
      :external_ipv4 => {
        :interface => "bond0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.18"
      }
    }
  },
  :postgresql => {
    :versions => ["13"],
    :settings => {
      :defaults => {
        :listen_addresses => "10.0.0.20",
        :work_mem => "160MB",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "60GB",
        :effective_io_concurrency => "256",
        :fsync => "on"
      }
    }
  },
  :apache => {
    :event => {
      :max_request_workers => 3000,
      :threads_per_child => 70
    }
  },
  :nominatim => {
    :state => "standalone",
    :dbadmins => %w[lonvia tomh],
    :dbcluster => "13/main",
    :postgis => "3",
    :enable_backup => true,
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :tablespaces => {
      "dosm" => "/ssd/tablespaces/dosm",
      "iosm" => "/ssd/tablespaces/iosm",
      "dplace" => "/ssd/tablespaces/dplace",
      "iplace" => "/ssd/tablespaces/iplace",
      "daddress" => "/ssd/tablespaces/daddress",
      "iaddress" => "/ssd/tablespaces/iaddress",
      "dsearch" => "/ssd/tablespaces/dsearch",
      "isearch" => "/ssd/tablespaces/isearch",
      "daux" => "/data/tablespaces/daux",
      "iaux" => "/data/tablespaces/iaux"
    }
  }
)

run_list(
  "role[ucl]",
  "role[nominatim]"
)
