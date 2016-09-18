name "pummelzacken"
description "Master role applied to pummelzacken"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "em1",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.20"
      },
      :external_ipv4 => {
        :interface => "em2",
        :role => :external,
        :family => :inet,
        :address => "128.40.45.204"
      }
    }
  },
  :postgresql => {
    :versions => ["9.3"],
    :settings => {
      :defaults => {
        :listen_addresses => "10.0.0.20",
        :work_mem => "160MB",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "60GB"
      }
    }
  },
  :nominatim => {
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :database => {
      :cluster => "9.3/main",
      :dbname => "nominatim",
      :postgis => "2.1"
    },
    :redirects => {
    }
  }
)

run_list(
  "role[ucl-wolfson]"
)
