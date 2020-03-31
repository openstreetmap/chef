name "bowser"
description "Master role applied to bowser"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "138.44.68.106",
        :prefix => "30",
        :gateway => "138.44.68.105",
        :bond => {
          :slaves => %w[ens14f0 ens14f1]
        }
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
  "role[aarnet]",
  "role[tile]"
)
