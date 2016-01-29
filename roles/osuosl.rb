name "osuosl"
description "Role applied to all servers at OSUOSL"

default_attributes(
  :accounts => {
    :users => {
      :osuadmin => { :status => :administrator }
    }
  },
  :hosted_by => "OSUOSL",
  :location => "Corvallis, Oregon",
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
    :roles => {
      :external => {
        :zone => "ool",
        :inet => {
          :prefix => "28",
          :gateway => "140.211.167.97"
        }
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["ntp.osuosl.org"]
  }
)

run_list(
  "role[us]"
)
