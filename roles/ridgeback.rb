name "ridgeback"
description "Master role applied to ridgeback"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "31.169.50.10",
        :prefix => "30",
        :gateway => "31.169.50.9"
      }
    }
  },
  :sysfs => {
    :md_tune => {
      :comment => "Tune the md sync performance so as not to kill system performance",
      :parameters => {
        "block/md0/md/sync_speed_min" => "10",
        "block/md0/md/sync_speed_max" => "10000",
        "block/md1/md/sync_speed_min" => "10",
        "block/md1/md/sync_speed_max" => "10000"
      }
    }
  },
  :squid => {
    :cache_mem => "5500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "oslo.render.openstreetmap.org",
    :tile_siblings => [
      "fume.openstreetmap.org",
      "trogdor.openstreetmap.org",
      "tabaluga.openstreetmap.org",
      "nepomuk.openstreetmap.org"
    ]
  }
)

run_list(
  "role[blix-no]",
  "role[tilecache]"
)
