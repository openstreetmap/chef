name "ucl-wolfson"
description "Role applied to all servers at UCL which are in Wolfson House"

default_attributes(
  :networking => {
    :roles => {
      :external => {
        :zone => "ucl",
        :inet => {
          :prefix => "27",
          :gateway => "128.40.45.222"
        }
      }
    }
  }
)

override_attributes(
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ],
    :search => [ "openstreetmap.org" ]
  }
)

run_list(
  "role[ucl]"
)
