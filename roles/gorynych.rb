name "gorynych"
description "Master role applied to gorynych"

default_attributes(
  :munin => {
    :plugins => {
      :smart_sdc => {
        :smartctl_exit_status => { :warning => ":8" }
      },
      :smart_sdd => {
        :smartctl_exit_status => { :warning => ":8" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "5.45.248.21",
        :prefix => "30",
        :gateway => "5.45.248.22"
      },
      :external_ipv6 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet6,
        :address => "2a02:6b8:b010:5065::a001",
        :prefix => "64",
        :gateway => "2a02:6b8:b010:5065::1"
      }
    }
  },
  :sysfs => {
    :md_tune => {
      :comment => "Tune the md sync performance so as not to kill system performance",
      :parameters => {
        "block/md0/md/sync_speed_min" => "1",
        "block/md0/md/sync_speed_max" => "100000"
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
      "noomoahk.openstreetmap.org",
      "cmok.openstreetmap.org"
    ]
  }
)

run_list(
  "role[yandex]",
  "role[tilecache]"
)
