name "yevaud"
description "Master role applied to yevaud"

default_attributes(
  :munin => {
    :plugins => {
      :cpu => {
        :system => { 
          :warning => 500,
          :critical => 600
        }
      },
      :load => {
        :load => { 
          :warning => 150,
          :critical => 200
        }
      },
      :ipmi_fans => {
        :contacts => "null",
      },
      :ipmi_temp => {
        :contacts => "null",
      },
      :sensors_fan => {
        :contacts => "null"
      },
      :sensors_temp => {
        :contacts => "null"
      },
      :sensors_volt => {
        :contacts => "null"
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.15"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.104"
      }
    }
  },
  :postgresql => {
    :versions => [ "9.1" ],
    :settings => {
      :defaults => {
        :shared_buffers => "3GB",
        :maintenance_work_mem => "7144MB",
        :effective_cache_size => "8GB"
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
  },
  :tile => {
    :tile_directory => "/store/tiles",
    :node_file => "/store/database/nodes"
  }
)

run_list(
  "role[ucl-internal]",
  "role[tile]"
)
