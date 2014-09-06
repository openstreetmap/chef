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
    :versions => [ "9.3" ],
    :settings => {
      :defaults => {
        :shared_buffers => "10GB",
        :work_mem => "160MB",
        :maintenance_work_mem => "20GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "60GB",
        :fsync => "off"
      }
    }
  },
  :nominatim => {
    :enabled => false,
    :database => {
        :cluster => "9.3/main",
        :dbname => "nominatim",
        :postgis => "2.1"
    },
    :fpm_pools => {
        :www => {
            :port => "8000",
            :pm => "dynamic",
            :max_children => "70"
        },
        :bulk => {
            :port => "8001",
            :pm => "static",
            :max_children => "10"
        }
    }
  }
)

run_list(
  "role[ucl-wolfson]",
  "role[nominatim]"
)
