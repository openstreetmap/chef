name "orm"
description "Master role applied to orm"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "bond0",
        :role => :external,
        :inet => {
          :address => "10.5.7.34",
          :prefix => "29",
          :gateway => "10.5.7.33",
          :public_address => "23.139.196.5"
        },
        :inet6 => {
          :address => "2602:f629:0:bc::2",
          :prefix => "64",
          :gateway => "2602:f629:0:bc::1"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer2+3",
          :slaves => %w[eno1 eno2]
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
      :cluster => "17/main",
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
  "role[pixeldeck]",
  "role[tile]"
)
