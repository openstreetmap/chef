name "smaug"
description "Master role applied to smaug"

default_attributes(
  :accounts => {
    :users => {
      :gravitystorm => { :status => :user }
    }
  },
  :apt => {
    :sources => ["brightbox-ruby-ng"]
  },
  :db => {
    :cluster => "9.1/main"
  },
  :munin => {
    :plugins => {
      :ipmi_fans => {
        :Fan4 => { :graph => "no" },
        :Fan7CPU1 => { :graph => "no" },
        :Fan8CPU2 => { :graph => "no" }
      },
      :sensors_volt => {
        :contacts => "null",
        :volt10 => {
          :warning => "3.11:3.50",
          :critical => "2.98:3.63"
        }
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.168"
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :shared_buffers => "16GB",
        :work_mem => "32MB",
        :maintenance_work_mem => "512MB",
        :effective_cache_size => "45GB"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => {
        "kernel.shmmax" => 17 * 1024 * 1024 * 1024,
        "kernel.shmall" => 17 * 1024 * 1024 * 1024 / 4096
      }
    }
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/sda/queue/nr_requests" => "512",
        "block/sdb/queue/nr_requests" => "512",
        "block/sda/queue/scheduler" => "noop",
        "block/sdb/queue/scheduler" => "noop"
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[db-slave]"
)
