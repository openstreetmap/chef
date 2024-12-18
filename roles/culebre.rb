name "culebre"
description "Master role applied to culebre"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.64.9"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[enp68s0f0 enp68s0f1 enp68s0f2 enp68s0f3]
        }
      },
      :external_he => {
        :interface => "bond0.101",
        :role => :external,
        :source_route_table => 100,
        :inet => {
          :address => "184.104.226.105",
          :prefix => "27",
          :gateway => "184.104.226.97"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::9",
          :prefix => 64,
          :gateway => "2001:470:1:b3b::1"
        }
      },
      :external => {
        :interface => "bond0.203",
        :role => :external,
        :metric => 150,
        :source_route_table => 150,
        :inet => {
          :address => "87.252.214.105",
          :prefix => "27",
          :gateway => "87.252.214.97"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::9",
          :prefix => 64,
          :gateway => "2001:4d78:fe03:1c::1"
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
  "role[equinix-dub]",
  "role[tile]"
)
