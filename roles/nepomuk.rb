name "nepomuk"
description "Master role applied to nepomuk"

default_attributes(
  :hardware => {
    :shm_size => "14g"
  },
  :networking => {
    :firewall => {
      :inet => [
        {
          :action => "ACCEPT",
          :source => "net:77.95.64.120,77.95.64.131,77.95.64.139",
          :dest => "fw",
          :proto => "tcp",
          :dest_ports => "5666",
          :source_ports => "1024:",
          :rate_limit => "-",
          :connection_limit => "-"
        }
      ]
    },
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "77.95.65.39",
        :prefix => "27",
        :gateway => "77.95.65.33"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2a03:9180:0:100::7",
        :prefix => "64",
        :gateway => "2a03:9180:0:100::1"
      }
    }
  },
  :sysctl => {
    :kvm => {
      :comment => "Tuning for KVM guest",
      :parameters => {
        "kernel.sched_min_granularity_ns" => 10000000,
        "kernel.sched_wakeup_granularity_ns" => 15000000
      }
    }
  },
  :squid => {
    :version => 4,
    :cache_mem => "10240 MB",
    :cache_dir => [
      "rock /store/squid/rock-4096 20000 swap-timeout=200 slot-size=4096 max-size=3996",
      "rock /store/squid/rock-8192 25000 swap-timeout=200 slot-size=8192 min-size=3997 max-size=8092",
      "rock /store/squid/rock-16384 35000 swap-timeout=200 slot-size=16384 min-size=8093 max-size=16284",
      "rock /store/squid/rock-32768 45000 swap-timeout=200 slot-size=32768 min-size=16285 max-size=262144"
    ]
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/vda/queue/nr_requests" => "128"
      }
    }
  },
  :tilecache => {
    :tile_parent => "france.render.openstreetmap.org"
  }
)

run_list(
  "role[lyonix]",
  "role[tilecache]"
)
