name "errol"
description "Master role applied to errol"

default_attributes(
  :munin => {
    :plugins => {
      :sensors_fan => {
        :contacts => "null"
      },
      :sensors_temp => {
        :contacts => "null"
      },
      :sensors_volt => {
        :contacts => "null",
        :volt10 => { 
          :warning => "3.11:3.50",
          :critical => "2.98:3.63"
        }
      }
    }
  },
  :devices => {
    :osdsk => {
      :comment => "First os disk",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff800",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "512"
      }
    },
    :homedsk => {
      :comment => "First home disk",
      :type => "block",
      :bus => "scsi",
      :serial => "20004d927fffff801",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "512"
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.14"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.103"
      }
    }
  }
);

run_list(
  "role[ucl-wates]",
  "role[dev]"
)
