name "idris"
description "Master role applied to idris"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.4"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.98"
      }
    }
  },
  :postgresql => {
    :versions => [ "9.1" ],
    :settings => {
      :defaults => {
        :shared_buffers => "1GB",
        :maintenance_work_mem => "256MB",
        :effective_cache_size => "2GB"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => { 
        "kernel.shmmax" => 4 * 1024 * 1024 * 1024,
        "kernel.shmall" => 4 * 1024 * 1024 * 1024 / 4096
      }
    }
  }
)

run_list(
  "role[ucl-internal]",
  "role[tile]"
)
