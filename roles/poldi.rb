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
        "block/md0/md/sync_speed_min" => "1",
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
        :address => "146.179.159.164"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.101"
      },
      :external_ipv6 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:2e0:81ff:fec5:333e"
      }
    }
  },
  :postgresql => {
    :versions => ["9.3"],
    :settings => {
      :defaults => {
        :shared_buffers => "10GB",
        :work_mem => "160MB",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "48GB",
        :fsync => "on"
      }
    }
  },
  :nominatim => {
    :enabled => false,
    :flatnode_file => "/ssd-old/nominatim/nodes.store",
    :database => {
      :cluster => "9.3/main",
      :dbname => "nominatim",
      :postgis => "2.1"
    },
    :fpm_pools => {
      :www => {
        :port => "8000",
        :pm => "dynamic",
        :max_children => "60"
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
  "role[ic]",
  "role[tyan-s7010]",
  "role[nominatim]"
)
