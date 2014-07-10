name "osuosl"
description "Role applied to all servers at OSUOSL"

default_attributes(
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ],
    :roles => {
      :internal => {
        :inet => {
          :prefix => "22",
          :gateway => "10.0.0.0"
        }
      },
      :external => {
        :zone => "osuosl"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "ntp.osuosl.org" ]
  }
)

run_list(
  "role[us]"
)
