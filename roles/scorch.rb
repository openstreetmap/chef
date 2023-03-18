name "scorch"
description "Master role applied to scorch"

default_attributes(
  :devices => {
    :ssd_system => {
      :comment => "Tune scheduler for system disk",
      :type => "block",
      :bus => "scsi",
      :serial => "3600605b009bbf5601fc3206407a43546",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "256",
        "queue/read_ahead_kb" => "2048"
      }
    }
  },
  :networking => {
    :interfaces => {
      :external => {
        :interface => "eth0",
        :role => :external,
        :inet => {
          :address => "176.31.235.79",
          :prefix => "24",
          :gateway => "176.31.235.254"
        },
        :inet6 => {
          :address => "2001:41d0:2:fc4f::1",
          :prefix => "64",
          :gateway => "2001:41d0:2:fcff:ff:ff:ff:ff"
        }
      }
    }
  }
)

run_list(
  "role[ovh]"
)
