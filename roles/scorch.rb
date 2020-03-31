name "scorch"
description "Master role applied to scorch"

default_attributes(
  :devices => {
    :ssd_system => {
      :comment => "Tune scheduler for system disk",
      :type => "block",
      :bus => "scsi",
      :serial => "3600605b009bbf5601fc3206407a43546",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "256",
        "queue/read_ahead_kb" => "2048"
      }
    }
  },
  :hardware => {
    :mcelog => {
      :enabled => false
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "176.31.235.79",
        :prefix => "24",
        :gateway => "176.31.235.254"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:41d0:2:fc4f::1",
        :prefix => "64",
        :gateway => "2001:41d0:2:fcff:ff:ff:ff:ff"
      }
    }
  },
  :postgresql => {
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
      :cluster => "12/main",
      :postgis => "3"
    },
    :styles => {
      :default => {
        :tile_directories => [
          { :name => "/store/tiles/default", :min_zoom => 0, :max_zoom => 19 }
        ]
      }
    }
  }
)

run_list(
  "role[ovh]",
  "role[tile]"
)
