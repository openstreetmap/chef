name "fume"
description "Master role applied to fume"

default_attributes(
  :munin => {
    :plugins => {
      :df => {
        :_dev_cciss_c0d1p1 => { :warning => ":95" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "85.30.190.241",
        :prefix => "29",
        :gateway => "85.30.190.246"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2a02:80:0:3ff8:222:64ff:fe2a:2714",
        :prefix => "64"
      }
    }
  },
  :squid => {
    :cache_mem => "16000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/cciss\!c0d0/queue/nr_requests" => "512",
        "block/cciss\!c0d1/queue/nr_requests" => "512",
        "block/cciss\!c0d0/queue/scheduler" => "noop",
        "block/cciss\!c0d1/queue/scheduler" => "noop"
      }
    }
  },
  :tilecache => {
    :tile_parent => "sjobo.render.openstreetmap.org",
    :tile_siblings => [
      "trogdor.openstreetmap.org",
      "ridgeback.openstreetmap.org",
      "katie.openstreetmap.org",
      "konqi.openstreetmap.org",
      "gorynych.openstreetmap.org",
      "nepomuk.openstreetmap.org"
    ]
  }
)

run_list(
  "role[teleservice]",
  "role[geodns]",
  "role[tilecache]"
)
