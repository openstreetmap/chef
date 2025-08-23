name "culebre"
description "Master role applied to culebre"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.9"
        },
        :bond => {
          :slaves => %w[enp68s0f0np0 enp68s0f1np1 enp68s0f2np2 enp68s0f3np3]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.105"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::9"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.105"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::9"
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
  "role[equinix-dub-public]",
  "role[tile]"
)
