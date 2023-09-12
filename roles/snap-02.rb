name "snap-02"
description "Master role applied to snap-02"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "eno1.2801",
        :role => :internal,
        :inet => {
          :address => "10.0.0.4"
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
  "role[ucl]",
  "role[db-slave]"
)
