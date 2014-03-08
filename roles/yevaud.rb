name "yevaud"
description "Master role applied to yevaud"

default_attributes(
  :devices => {
    :osdisktune1 => {
      :comment => "Tune os disk",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff800",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "512"
      }
    },
    :disktune2 => {
      :comment => "Tune database array",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff802",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "512"
      }
    },
    :disktune3 => {
      :comment => "Tune os disk",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff803",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "512"
      }
    },
    :ssdtune1 => {
      :comment => "Tune ssd disk",
      :type => "block",
      :bus => "ata",
      :serial => "INTEL_SSDSA2CW600G3_CVPR111401HP600FGN",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "512",
        "queue/read_ahead_kb" => "2048"
      }
    }
  },
  :munin => {
    :plugins => {
      :cpu => {
        :system => { 
          :warning => 500,
          :critical => 600
        }
      },
      :load => {
        :load => { 
          :warning => 150,
          :critical => 200
        }
      },
      :ipmi_fans => {
        :contacts => "null",
      },
      :ipmi_temp => {
        :contacts => "null",
      },
      :sensors_fan => {
        :contacts => "null"
      },
      :sensors_temp => {
        :contacts => "null"
      },
      :sensors_volt => {
        :contacts => "null"
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.15"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.104"
      }
    }
  },
  :postgresql => {
    :versions => [ "9.1" ],
    :settings => {
      :defaults => {
        :shared_buffers => "3GB",
        :maintenance_work_mem => "7144MB",
        :effective_cache_size => "8GB"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => { 
        "kernel.shmmax" => 4 * 1024 * 1024 * 1024,
        "kernel.shmall" => 4 * 1024 * 1024 * 1024 / 4096
      }
    }
  },
  :tile => {
    :node_file => "/store/database/nodes",
    :styles => {
      :default => {
        :tile_directories => [
          { :name => "/store/tiles/default-low", :min_zoom => 0, :max_zoom => 16 },
          { :name => "/store/tiles/default-high", :min_zoom => 17, :max_zoom => 19 }
        ]
      }
    }
  }
)

run_list(
  "role[ucl-internal]",
  "role[tile]"
)
