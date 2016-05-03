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
      },
      :external_ipv4 => {
        :role => :external,
        :family => :inet,
        :address => "52.50.86.69"
      }
    }
  },
  :openvpn => {
    :address => "10.0.16.4",
    :tunnels => {
      :aws2ic => {
        :port => "1194",
        :mode => "client",
        :peer => {
          :host => "ironbelly.openstreetmap.org"
        }
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
  "role[aws]",
  "recipe[openvpn]"
)
