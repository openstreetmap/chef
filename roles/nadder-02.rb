name "nadder-02"
description "Master role applied to nadder-02"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "192.163.219.40",
        :prefix => "19",
        :gateway => "192.163.192.1"
      }
    }
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/vda/queue/nr_requests" => "512",
        "block/vdb/queue/nr_requests" => "512",
        "block/vda/queue/scheduler" => "deadline",
        "block/vdb/queue/scheduler" => "deadline"
      }
    }
  },
  :squid => {
    :cache_mem => "6500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "orm.openstreetmap.org"
  }
)

run_list(
  "role[bluehost]",
  "role[tilecache]"
)
