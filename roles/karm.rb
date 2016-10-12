name "karm"
description "Master role applied to karm"

default_attributes(
  :apt => {
    :sources => ["postgresql"]
  },
  :db => {
    :cluster => "9.1/main"
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp1s0f0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.168",
        :hwaddress => "0c:c4:7a:a3:aa:ac"
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :shared_buffers => "64GB",
        :work_mem => "64MB",
        :maintenance_work_mem => "1GB",
        :effective_cache_size => "180GB",
        :effective_io_concurrency => "256"
      }
    },
    :versions => ["9.1"]
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => {
        "kernel.shmmax" => 66 * 1024 * 1024 * 1024,
        "kernel.shmall" => 66 * 1024 * 1024 * 1024 / 4096
      }
    }
  },
  :sysfs => {
    :md_tune => {
      :comment => "Enable request merging for NVMe devices",
      :parameters => {
        "block/nvme0n1/queue/nomerges" => "1",
        "block/nvme1n1/queue/nomerges" => "1",
        "block/nvme2n1/queue/nomerges" => "1",
        "block/nvme3n1/queue/nomerges" => "1",
        "block/nvme4n1/queue/nomerges" => "1",
        "block/nvme5n1/queue/nomerges" => "1"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[db-slave]"
)
