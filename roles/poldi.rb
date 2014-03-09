name "poldi"
description "Master role applied to poldi"

default_attributes(
  :devices => {
    :areca_ld_tune => {
      :comment => "RAID arrays on areca",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff*",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/read_ahead_kb" => "2048"
      }
    },
    :ssd_samsung_tune => {
      :comment => "Tune Samsung SSD",
      :type => "block",
      :bus => "ata",
      :serial => "Samsung_SSD_840_PRO_Series_*",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "256",
        "queue/read_ahead_kb" => "2048"
      }
    }
  },
  :sysfs => {
    :md_tune => {
      :comment => "Tune the md sync performance so as not to kill system performance",
      :parameters => {
        "block/md0/md/sync_speed_min" => "100",
        "block/md0/md/sync_speed_max" => "100000"
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
            :max_children => "80"
        },
        :bulk => {
            :pm => "static",
            :max_children => "10"
        }
    }
  },
  :munin => {
    :plugins => {
      :sensors_volt => {
        :volt6 => {
          :warning => "2.99:3.54",
          :critical => "2.50:4.00"
        }
      }
    }
  }
)

run_list(
  "role[ucl-internal]",
  "role[nominatim]"
)
