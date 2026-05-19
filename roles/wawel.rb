name "wawel"
description "Master role applied to wawel"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "ens3",
        :role => :external,
        :inet => {
          :address => "10.0.0.51",
          :prefix => "24",
          :gateway => "10.0.0.1",
          :public_address => "64.225.136.96"
        }
      }
    }
  },
  :apache => {
    :event => {
      :start_servers => 8,
      :threads_per_child => 64,
      :min_spare_threads => 512,
      :max_spare_threads => 2048,
      :max_request_workers => 4096,
      :max_connections_per_child => 0,
      :async_request_worker_factor => 12,
      :listen_cores_buckets_ratio => 8
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

run_list(
  "role[cloudferro-waw3-2]",
  "role[tile]"
)
