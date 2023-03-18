name "nepomuk"
description "Master role applied to nepomuk"

default_attributes(
  :networking => {
    :firewall => {
      :incoming => [
        "tcp sport { 1024-65535 } tcp dport { 5666 } ip saddr { 77.95.64.120, 77.95.64.131, 77.95.64.139 } ct state new accept"
      ]
    },
    :interfaces => {
      :external => {
        :interface => "eth0",
        :role => :external,
        :inet => {
          :address => "77.95.65.39",
          :prefix => "27",
          :gateway => "77.95.65.33"
        },
        :inet6 => {
          :address => "2a03:9180:0:100::7",
          :prefix => "64",
          :gateway => "2a03:9180:0:100::1"
        }
      }
    }
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/vda/queue/nr_requests" => "128"
      }
    }
  }
)

run_list(
  "role[lyonix]"
)
