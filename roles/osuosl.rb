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
  :timezone => "PST8PDT",
  :networking => {
    :roles => {
      :external => {
        :inet => {
          :prefix => "28",
          :gateway => "140.211.167.97"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "2605:bc80:3010:700::1"
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
