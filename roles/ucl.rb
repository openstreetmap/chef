name "ucl"
description "Role applied to all servers at UCL"

default_attributes(
  :bind => {
    :forwarders => [ "144.82.100.1", "144.82.100.41" ]
  },
  :sysctl => {
    :sack => {
      :comment => "Disable SACK as the UCL firewall breaks it",
      :parameters => { 
        "net.ipv4.tcp_sack" => "0"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "ntp1.ucl.ac.uk", "ntp2.ucl.ac.uk" ]
  }
)

run_list(
  "role[gb]"
)
