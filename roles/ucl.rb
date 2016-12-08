name "ucl"
description "Role applied to all servers at UCL"

default_attributes(
  :location => "Slough, England",
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
          :gateway => "193.60.236.254"
        }
      }
    }
  }
)

override_attributes(
  :networking => {
    :nameservers => ["10.0.0.3", "8.8.8.8", "8.8.4.4"],
    :search => ["ucl.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["0.uk.pool.ntp.org", "1.uk.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[gb]"
)
