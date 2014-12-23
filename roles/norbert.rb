name "norbert"
description "Master role applied to norbert"

default_attributes(
  :accounts => {
    :users => {
      :yellowbkpk => { :status => :administrator },
      :pnorman => { :status => :user }
    }
  },
  :exim => {
    :aliases => {
      :root => "yellowbkpk"
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.5"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.45.202"
      }
    }
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/cciss\!c0d0/queue/nr_requests" => "512",
        "block/cciss\!c0d1/queue/nr_requests" => "512",
	"block/cciss\!c0d0/queue/scheduler" => "noop",
	"block/cciss\!c0d1/queue/scheduler" => "noop",
	"block/sda/queue/nr_requests" => "512",
	"block/sda/queue/scheduler" => "deadline"
      }
    }
  }
)

run_list(
  "role[ucl-wolfson]",
  "role[hp-g5]"
)
