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
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :shared_buffers => "24GB",
        :work_mem => "160MB",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "48GB"
      }
    }
  },
  :nominatim => {
    :fpm_pools => {
        :www => {
            :pm => "dynamic",
            :max_children => "70"
        },
        :bulk => {
            :pm => "static",
            :max_children => "10"
        }
    }
  }
)

run_list(
  "role[ucl-internal]"
)
