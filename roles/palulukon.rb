name "palulukon"
description "Master role applied to palulukon"

default_attributes(
  :networking => {
    :firewall => {
      :allowlist => ["172.31.0.2"]
    },
    :interfaces => {
      :external => {
        :interface => "ens5",
        :role => :external,
        :inet => {
          :address => "172.31.14.117",
          :prefix => "20",
          :gateway => "172.31.0.1",
          :public_address => "3.144.0.72"
        },
        :inet6 => {
          :address => "2600:1f16:126d:9400:48bc:5b5e:6d26:beb8",
          :prefix => "64",
          :gateway => "2600:1f16:126d:9400::1"
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
    :styles => {
      :default => {
        :tile_directories => [
          { :name => "/store/tiles/default", :min_zoom => 0, :max_zoom => 19 }
        ]
      }
    }
  }
)

override_attributes(
  :networking => {
    :nameservers => ["172.31.0.2"]
  }
)

run_list(
  "role[aws-us-east-2]",
  "role[tile]"
)
