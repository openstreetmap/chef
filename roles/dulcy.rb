name "dulcy"
description "Master role applied to dulcy"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.9"
        },
        :bond => {
          :slaves => %w[enp1s0f0 enp1s0f1]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.179.137"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::9"
        }
      },
      :equinix => {
        :inet => {
          :address => "82.199.86.105"
        },
        :inet6 => {
          :address => "2001:4d78:500:5e3::9"
        }
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
        "devices/system/cpu/cpu31/power/energy_perf_bias" => "0"
      }
    }
  },
  :postgresql => {
    :versions => ["17"],
    :settings => {
      :defaults => {
        :work_mem => "240MB",
        :effective_io_concurrency => "500"
      }
    }
  },
  :nominatim => {
    :dbcluster => "17/main",
    :flatnode_file => "/srv/nominatim.openstreetmap.org/planet-project/nodes.store",
    :enable_qa_tiles => false,
    :api_workers => 12,
    :api_pool_size => 10
  }
)

run_list(
  "role[equinix-ams-public]",
  "role[nominatim]"
)
