name "fafnir"
description "Master role applied to fafnir"

default_attributes(
  :db => {
    :cluster => "9.1/main"
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "172.31.10.210",
        :hwaddress => "02:c1:c5:8b:5f:1d"
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :shared_buffers => "64GB",
        :work_mem => "64MB",
        :maintenance_work_mem => "1GB",
        :effective_cache_size => "180GB"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => {
        "kernel.shmmax" => 66 * 1024 * 1024 * 1024,
        "kernel.shmall" => 66 * 1024 * 1024 * 1024 / 4096
      }
    }
  }
)

run_list(
  "role[aws]"
)
