name "ucl-wates"
description "Role applied to all servers at UCL which are in Wates House"

default_attributes(
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
  :networking => {
    :nameservers => [ "10.0.0.3", "8.8.8.8", "8.8.4.4" ],
    :search => [ "ucl.openstreetmap.org", "openstreetmap.org" ]
  }
)

run_list(
  "role[ucl]"
)
