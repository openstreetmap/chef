name "ysera"
description "Master role applied to ysera"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "eno1.2801",
        :role => :internal,
        :inet => {
          :address => "10.0.0.15"
        }
      },
      :external => {
        :interface => "eno1.2800",
        :role => :external,
        :inet => {
          :address => "193.60.236.22"
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
    }
  }
)

run_list(
  "role[ucl]",
  "role[tile]"
)
