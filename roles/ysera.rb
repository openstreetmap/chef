name "ysera"
description "Master role applied to ysera"

default_attributes(
  :apt => {
    :sources => ["postgresql"],
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eno1.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.15",
      },
      :external_ipv4 => {
        :interface => "eno1.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.22",
      },
    },
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
  "role[ucl]",
  "role[tile]"
)
