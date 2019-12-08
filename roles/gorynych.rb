name "gorynych"
description "Master role applied to gorynych"

default_attributes(
  :hardware => {
    :shm_size => "20g"
  },
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
    :version => 4,
    :cache_mem => "16384 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :nginx => {
    :cache => {
      :proxy => {
        :directory => "/store/nginx-cache/proxy-cache",
        :max_size => "32768M"
      }
    }
  },
  :tilecache => {
    :tile_parent => "moscow.render.openstreetmap.org"
  }
)

run_list(
  "role[yandex]",
  "role[tilecache]"
)
