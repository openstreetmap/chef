name "necrosan"
description "Master role applied to necrosan"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :mtu => 9000,
        :role => :external,
        :family => :inet,
        :address => "45.85.134.91",
        :prefix => "31",
        :gateway => "45.85.134.90",
        :bond => {
          :slaves => %w[eno1 eno2],
          :mode => "802.3ad",
          :lacprate => "fast"
        }
      },
      :external_ipv6 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet6,
        :address => "2a05:46c0:100:1004:ffff:ffff:ffff:ffff",
        :prefix => "64",
        :gateway => "2a05:46c0:100:1004::"
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
  "role[appliwave]",
  "role[tile]"
)
