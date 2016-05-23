name "karm"
description "Master role applied to karm"

default_attributes(
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
  "role[ic]"
)
