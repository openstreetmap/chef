name "ucl"
description "Role applied to all servers at UCL"

default_attributes(
  :location => "Slough, England",
  :networking => {
    :roles => {
      :internal => {
        :inet => {
          :prefix => "20",
          :gateway => "10.0.0.3",
          :routes => {
            "10.0.0.0/8" => { :via => "10.0.0.3" }
          }
        }
      },
      :external => {
        :zone => "ucl",
        :inet => {
          :prefix => "24",
          :gateway => "193.60.236.254"
        }
      }
    },
    :wireguard => {
      :keepalive => 180
    }
  }
)

override_attributes(
  :networking => {
    :nameservers => ["10.0.0.3", "1.1.1.1", "1.0.0.1"],
    :search => ["ucl.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["ntp1.ucl.ac.uk", "ntp2.ucl.ac.uk"]
  }
)

run_list(
  "role[gb]"
)
