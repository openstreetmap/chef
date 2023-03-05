name "palulukon"
description "Master role applied to palulukon"

default_attributes(
  :networking => {
    :firewall => {
      :whitelist => ["172.31.0.2"]
    },
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens5",
        :role => :external,
        :family => :inet,
        :address => "172.31.37.101",
        :prefix => "20",
        :gateway => "172.31.32.1",
        :public_address => "3.144.0.72"
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
      :cluster => "14/main",
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

override_attributes(
  :networking => {
    :nameservers => ["172.31.0.2"]
  }
)

run_list(
  "role[aws-us-east-2]",
  "role[tile]"
)
