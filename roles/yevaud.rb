name "yevaud"
description "Master role applied to yevaud"

default_attributes(
  :apt => {
    :sources => ["postgresql"]
  },
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
          :warning => 400,
          :critical => 500
        }
      },
      :sensors_temp => {
        :temp1 => { :warning => 82 },
        :temp2 => { :warning => 82 },
        :temp3 => { :warning => 82 },
        :temp4 => { :warning => 82 },
        :temp5 => { :warning => 82 },
        :temp6 => { :warning => 82 }
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.15"
      },
      :external_ipv4 => {
        :interface => "eth0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.22"
      }
    }
  },
  :postgresql => {
    :versions => ["9.6"],
    :settings => {
      :defaults => {
        :shared_buffers => "8GB",
        :maintenance_work_mem => "7144MB",
        :effective_cache_size => "16GB"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => {
        "kernel.shmmax" => 9 * 1024 * 1024 * 1024,
        "kernel.shmall" => 9 * 1024 * 1024 * 1024 / 4096
      }
    }
  },
  :tile => {
    :database => {
      :cluster => "9.6/main",
      :postgis => "2.3"
    },
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
  "role[ucl]",
  "role[tyan-s7010]",
  "role[tile]"
)
