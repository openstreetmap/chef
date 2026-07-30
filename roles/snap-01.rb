name "snap-01"
description "Master role applied to snap-01"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.48.49"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4]
        }
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :shared_buffers => "128GB",
        :work_mem => "128MB",
        :maintenance_work_mem => "2GB",
        :effective_cache_size => "360GB"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => {
        "kernel.shmmax" => 132 * 1024 * 1024 * 1024,
        "kernel.shmall" => 132 * 1024 * 1024 * 1024 / 4096
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[db-master]",
  "role[db-backup]"
)
