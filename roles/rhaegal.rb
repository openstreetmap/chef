name "rhaegal"
description "Master role applied to rhaegal"

default_attributes(
  :accounts => {
    :users => {
      :mmiler => { :status => :administrator }
    }
  },
  :location => "Zagreb, Croatia",
  :munin => {
    :plugins => {
      :sensors_temp => {
        :temp1 => { :warning => "85.0" },
        :temp2 => { :warning => "85.0" },
        :temp3 => { :warning => "85.0" },
        :temp4 => { :warning => "85.0" },
        :temp5 => { :warning => "85.0" },
        :temp6 => { :warning => "85.0" },
        :temp8 => { :warning => "85.0" },
        :temp9 => { :warning => "85.0" },
        :temp10 => { :warning => "85.0" },
        :temp11 => { :warning => "85.0" },
        :temp12 => { :warning => "85.0" },
        :temp13 => { :warning => "85.0" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "10.5.0.77",
        :prefix => "16",
        :gateway => "10.5.0.1",
        :public_address => "161.53.248.77"
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
    :replication => {
      :url => "https://planet.osm.org/replication/test/minute/"
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
  "role[carnet]",
  "role[tile]"
)
