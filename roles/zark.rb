name "zark"
description "Master role applied to zark"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth1.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.8"
      },
      :external_ipv4 => {
        :interface => "eth1.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.23"
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :shared_buffers => "2GB",
        :work_mem => "8MB",
        :maintenance_work_mem => "32MB",
        :effective_cache_size => "4GB"
      }
    }
  }
)

run_list(
  "role[ucl-slough]",
  "role[owl]"
)
