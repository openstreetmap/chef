name "poldi"
description "Master role applied to poldi"

default_attributes(
  :devices => {
    :ubuntu => {
      :comment => "RAID array backing the ubuntu volume group",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff800",
      :attrs => {
        "queue/scheduler" => "deadline"
      }
    },
    :nominatim => {
      :comment => "RAID array backing the nominatim volume group",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff801",
      :attrs => {
        "queue/scheduler" => "deadline"
      }
    },
    :nominatim2 => {
      :comment => "RAID array backing the nominatim2 volume group",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff802",
      :attrs => {
        "queue/scheduler" => "deadline"
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.16"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.106"
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :shared_buffers => "9GB",
        :work_mem => "160MB",
        :maintenance_work_mem => "9GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "48GB"
      }
    }
  }
)

run_list(
  "role[ucl-internal]",
  "role[nominatim]"
)
