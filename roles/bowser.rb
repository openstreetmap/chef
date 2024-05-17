name "bowser"
description "Master role applied to bowser"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "bond0",
        :role => :external,
        :inet => {
          :address => "138.44.68.106",
          :prefix => "30",
          :gateway => "138.44.68.105"
        },
        :bond => {
          :slaves => %w[ens14f0np0 ens14f1np1]
        }
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
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
      :cluster => "16/main",
      :postgis => "3"
    },
    :mapnik => "3.1",
    :replication => {
      :directory => "/store/replication"
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
