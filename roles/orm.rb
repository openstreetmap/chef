name "orm"
description "Master role applied to orm"

default_attributes(
  :devices => {
    :ssd_samsung => {
      :comment => "Tune scheduler for SSD",
      :type => "block",
      :bus => "ata",
      :serial => "Samsung_SSD_840_PRO_Series_*",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "256",
        "queue/read_ahead_kb" => "2048"
      }
    },
    :arecavoltune => {
      :comment => "Tune scheduler for Areca",
      :type => "block",
      :bus => "scsi",
      :serial => "2001b4d20*",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "512",
        "queue/read_ahead_kb" => "2048"
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.98"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:2e0:81ff:fec5:2a8c"
      }
    }
  },
  :postgresql => {
    :versions => [ "9.1" ],
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
    :node_file => "/store/database/nodes",
    :styles => {
      :default => {
        :tile_directories => [
          { :name => "/store/tiles/default-low", :min_zoom => 0, :max_zoom => 17 },
          { :name => "/store/tiles/default-high", :min_zoom => 18, :max_zoom => 19 }
        ]
      }
    }
  }
)

override_attributes(
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ]
  }
)

run_list(
  "role[ic]",
  "role[tyan-s7010]",
  "role[tile]"
)
