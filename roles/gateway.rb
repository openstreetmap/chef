name "gateway"
description "Role applied to all network gateways"

default_attributes(
  :sysctl => {
    :network_forwarding => {
      :comment => "Enable forwarding",
      :parameters => { "net.ipv4.ip_forward" => "1" }
    }
  },
  :exim => {
    :relay_from_hosts => [ "10.0.0.0/8"]
  }
)

run_list(
  "recipe[bind]"
)
