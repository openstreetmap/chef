name "ucl"
description "Role applied to all servers at UCL"

default_attributes(
  :bind => {
    :forwarders => [ "144.82.100.1", "144.82.100.41" ]
  },
  :networking => {
    :roles => {
      :internal => {
        :inet => {
          :prefix => "20",
          :gateway => "10.0.0.3"
        }
      },
      :external => {
        :zone => "ucl",
        :inet => {
          :prefix => "24",
          :gateway => "128.40.168.126"
        }
      }
    }
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
