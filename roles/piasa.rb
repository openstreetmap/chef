name "piasa"
description "Master role applied to piasa"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "bond0",
        :role => :external,
        :inet => {
          :address => "140.211.167.101"
        },
        :inet6 => {
          :address => "2605:bc80:3010:700::8cd3:a765"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
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
    :styles => {
      :default => {
        :tile_directories => [
          { :name => "/store/tiles/default", :min_zoom => 0, :max_zoom => 19 }
        ]
      }
    },
  }
)

run_list(
  "role[osuosl]",
  "role[tile]"
)
