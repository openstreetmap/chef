name "ridgeback"
description "Master role applied to ridgeback"

default_attributes(
  :hardware => {
    :ipmi => {
      :excluded_sensors => [19, 20, 21, 22]
    }
  },
  :munin => {
    :plugins => {
      :ipmi_fans => {
        :Fan4 => { :graph => "no", :warning => "0:" },
        :Fan5 => { :graph => "no", :warning => "0:" },
        :Fan6 => { :graph => "no", :warning => "0:" },
        :Fan7CPU1 => { :graph => "no", :warning => "0:" }
      },
      :smart_sda => {
        :smartctl_exit_status => {
          :warning => 8
        }
      },
      :smart_sdb => {
        :smartctl_exit_status => {
          :warning => 8
        }
      }
    }
  },
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
        "block/md0/md/sync_speed_min" => "1",
        "block/md0/md/sync_speed_max" => "100000",
        "block/md1/md/sync_speed_min" => "1",
        "block/md1/md/sync_speed_max" => "100000"
      }
    }
  }
)

run_list(
  "role[blix-no]",
  "role[geodns]"
)
