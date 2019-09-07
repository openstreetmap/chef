name "rhaegal"
description "Master role applied to rhaegal"

default_attributes(
  :accounts => {
    :users => {
      :mmiler => { :status => :administrator },
    },
  },
  :apt => {
    :sources => ["postgresql"],
  },
  :devices => {
    :ssd_samsung => {
      :comment => "Tune scheduler for SSD",
      :type => "block",
      :bus => "ata",
      :serial => "Samsung_SSD_860_PRO_*",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "256",
        "queue/read_ahead_kb" => "2048",
      },
    },
  },
  :location => "Zagreb, Croatia",
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "enp1s0f0",
        :role => :external,
        :family => :inet,
        :address => "10.5.0.77",
        :prefix => "16",
        :gateway => "10.5.0.1",
        :public_address => "161.53.248.77",
      },
    },
    :nameservers => [
      "10.5.0.7",
      "8.8.8.8",
    ],
  },
  :postgresql => {
    :versions => ["10"],
    :settings => {
      :defaults => {
        :shared_buffers => "8GB",
        :maintenance_work_mem => "7144MB",
        :effective_cache_size => "16GB",
      },
    },
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => {
        "kernel.shmmax" => 9 * 1024 * 1024 * 1024,
        "kernel.shmall" => 9 * 1024 * 1024 * 1024 / 4096,
      },
    },
  },
  :tile => {
    :database => {
      :cluster => "10/main",
      :postgis => "2.4",
    },
    :node_file => "/store/database/nodes",
    :styles => {
      :default => {
        :tile_directories => [
          { :name => "/store/tiles/default", :min_zoom => 0, :max_zoom => 19 },
        ],
      },
    },
  }
)

run_list(
  "role[carnet]",
  "role[tile]"
)
