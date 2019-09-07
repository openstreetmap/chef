name "pyrene"
description "Master role applied to pyrene"

default_attributes(
  :apt => {
    :sources => ["postgresql"],
  },
  :munin => {
    :plugins => {
      :hpasmcli2_temp => {
        :temp15 => { :warning => "59.5", :critical => "70" },
        :temp17 => { :warning => "59.5", :critical => "70" },
      },
    },
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "140.211.167.98",
      },
      :external_ipv6 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet6,
        :address => "2605:bc80:3010:700::8cd3:a762",
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
  "role[osuosl]",
  "role[tile]"
)
