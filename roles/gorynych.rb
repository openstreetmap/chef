name "gorynych"
description "Master role applied to gorynych"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "130.193.62.73",
        :prefix => "29",
        :gateway => "130.193.62.78"
      }
    }
  },
  :sysfs => {
    :md_tune => {
      :comment => "Tune the md sync performance so as not to kill system performance",
      :parameters => {
        "block/md0/md/sync_speed_min" => "10",
        "block/md0/md/sync_speed_max" => "10000"
      }
    }
  },
  :squid => {
    :cache_mem => "5800 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "moscow.render.openstreetmap.org",
    :tile_siblings => [
      "nepomuk.openstreetmap.org",
      "tabaluga.openstreetmap.org",
      "fume.openstreetmap.org"
    ]
  }
)

run_list(
  "role[yandex]",
  "role[tilecache]"
)
