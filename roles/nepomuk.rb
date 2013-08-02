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
        :address => "2001:7f8:47:21::a6",
        :prefix => "64",
        :gateway => "2001:7f8:47:21::a1"
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
        "block/vda/queue/nr_requests" => "512",
	"block/vda/queue/scheduler" => "noop"
      }
    }
  }
)

run_list(
  "role[lyonix]",
  "role[tilecache]"
)
