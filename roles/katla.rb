name "katla"
description "Master role applied to katla"

default_attributes(
  :db => {
    :cluster => "9.1/main"
  },
  :devices => {
    :store_slow => {
      :comment => "RAID array mounted on /store/arrays/slow",
      :type => "block",
      :bus => "scsi",
      :serial => "3600605b005a0609019290f178be8de77",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "975"
      }
    },
    :store_fast => {
      :comment => "RAID array mounted on /store/arrays/fast",
      :type => "block",
      :bus => "scsi",
      :serial => "3600605b005a0726019d062ae23b426fd",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "975"
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.173",
        :hwaddress => "00:25:90:94:91:00"
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
);

run_list(
  "role[ic]",
  "role[db-slave]"
)
