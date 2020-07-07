name "pyrene"
description "Master role applied to pyrene"

default_attributes(
  :munin => {
    :plugins => {
      :hpasmcli2_temp => {
        :temp15 => { :warning => "59.5", :critical => "70" },
        :temp17 => { :warning => "59.5", :critical => "70" }
      },
      :hpasmcli2_fans => {
        :fan1 => { :warning => "95", :critical => "100" },
        :fan2 => { :warning => "95", :critical => "100" },
        :fan3 => { :warning => "95", :critical => "100" },
        :fan4 => { :warning => "95", :critical => "100" },
        :fan5 => { :warning => "95", :critical => "100" },
        :fan6 => { :warning => "95", :critical => "100" },
        :fan7 => { :warning => "95", :critical => "100" },
        :fan8 => { :warning => "95", :critical => "100" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "140.211.167.98"
      },
      :external_ipv6 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet6,
        :address => "2605:bc80:3010:700::8cd3:a762"
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
  "role[osuosl]",
  "role[tile]"
)
