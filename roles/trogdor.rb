name "trogdor"
description "Master role applied to trogdor"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "134.90.146.26",
        :prefix => "30",
        :gateway => "134.90.146.25"
      }
    }
  },
  :sysfs => {
    :md_tune => {
      :comment => "Tune the md sync performance so as not to kill system performance",
      :parameters => {
        "block/md0/md/sync_speed_min" => "1",
        "block/md0/md/sync_speed_max" => "100000",
        "block/md1/md/sync_speed_min" => "1",
        "block/md1/md/sync_speed_max" => "100000"
      }
    }
  },
  :squid => {
    :cache_mem => "6400 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "amsterdam.render.openstreetmap.org",
    :tile_siblings => [
      "fume.openstreetmap.org",
      "tabaluga.openstreetmap.org",
      "nepomuk.openstreetmap.org",
      "ridgeback.openstreetmap.org"
    ]
  }
)

run_list(
  "role[blix-nl]",
  "role[tilecache]"
)
