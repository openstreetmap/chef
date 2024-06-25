name "odin"
description "Master role applied to odin"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.15"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1np0 eno2np1]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.143"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::f"
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
  :sysfs => {
    :cpu_power_energy_perf_bias => {
      :parameters => {
        "devices/system/cpu/cpu0/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu1/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu2/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu3/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu4/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu5/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu6/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu7/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu8/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu9/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu10/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu11/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu12/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu13/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu14/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu15/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu16/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu17/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu18/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu19/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu20/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu21/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu22/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu23/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu24/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu25/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu26/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu27/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu28/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu29/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu30/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu31/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu32/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu33/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu34/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu35/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu36/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu37/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu38/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu39/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu40/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu41/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu42/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu43/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu44/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu45/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu46/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu47/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu48/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu49/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu50/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu51/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu52/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu53/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu54/power/energy_perf_bias" => "0",
        "devices/system/cpu/cpu55/power/energy_perf_bias" => "0"
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
  "role[equinix-ams]",
  "role[tile]"
)
