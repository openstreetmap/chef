name "ramoth"
description "Master role applied to ramoth"

default_attributes(
  :accounts => {
    :users => {
      :osmbackup => { :status => :role }
    }
  },
  :db => {
    :cluster => "9.1/main"
  },
  :devices => {
    :store_openstreetmap => {
      :comment => "RAID array mounted on /store/postgresql/openstreetmap",
      :type => "block",
      :bus => "scsi",
      :serial => "3600605b0039483a017092ecbe862082a",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "975"
      }
    },
    :store_system => {
      :comment => "RAID array mounted on /store/postgresql/system",
      :type => "block",
      :bus => "scsi",
      :serial => "3600605b0039483a017092ff8fa5a6332",
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
        :address => "146.179.159.170",
        :hwaddress => "00:25:90:4b:05:9a"
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
  "role[db-master]",
  "role[db-backup]"
)
