name "nepomuk"
description "Master role applied to nepomuk"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "77.95.70.166",
        :prefix => "27",
        :gateway => "77.95.70.161"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2a03:9180:1:21::a6",
        :prefix => "64",
        :gateway => "2a03:9180:1:21::a1"
      }
    }
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/vda/queue/nr_requests" => "64",
        "block/vda/queue/scheduler" => "deadline"
      }
    }
  },
  :tilecache => {
    :tile_parent => "lyon.render.openstreetmap.org",
    :tile_siblings => [
      "trogdor.openstreetmap.org",
      "lurien.openstreetmap.org",
      "tabaluga.openstreetmap.org"
    ]
  }
)

run_list(
  "role[lyonix]",
  "role[tilecache]"
)
